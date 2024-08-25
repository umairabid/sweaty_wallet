class TransactionsController < ApplicationController
  before_action :set_filter, only: %i[index]
  before_action :set_repository, only: %i[index]

  def index
    scope = @repo.fetch_by_filters @filter
    @transactions = set_page_and_extract_portion_from scope
  end

  def export
    job = Transactions::ExportJob.perform_later(current_user, filters: params[:filter])
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          :background_processing_modal,
          partial: "helpers/background_processing_modal",
          locals: { job_id: job.job_id },
        )
      end
    end
  end

  private

  def set_filter
    @filter = TransactionFilter.new(current_user, params[:filter] || {})
  end

  def set_repository
    @repo = TransactionsRepository.new(current_user.transactions)
  end
end
