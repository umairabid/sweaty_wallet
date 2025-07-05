class TransactionsController < ApplicationController
  before_action :set_user_references, only: %i[index update]
  before_action :set_transaction, only: %i[update destroy]
  before_action :set_columns, only: %i[index update]
  before_action :set_filter, only: %i[index suggest_categories]

  def index; end

  def export
    job = Transactions::ExportJob.perform_later(current_user, filters: params[:filter])

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          :background_processing_modal,
          partial: 'helpers/background_processing_modal',
          locals: { job_id: job.job_id }
        )
      end
    end
  end

  def update
    @transaction = Transactions::Update.call(current_user, @transaction,
                                             params.require(:transaction))
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "transaction_row_#{@transaction.id}",
          partial: 'transactions/transaction_row',
          locals: { transaction: @transaction, references: @user_references, columns: @columns }
        )
      end
    end
  end

  def create
    @transaction = Transactions::Create.call(current_user, Transaction.new,
                                             params.require(:transaction))
    redirect_to transactions_path
  end

  def destroy
    @transaction.soft_delete
    redirect_params = params.to_unsafe_hash
    redirect_to transactions_path(filter: redirect_params[:filter],
                                  columns: redirect_params[:columns], page: redirect_params[:page])
  end

  def suggest_categories
    job = Transactions::SetSuggestedCategoriesJob.perform_later(current_user, params[:ids] || [])
    render json: { job_id: job.job_id }
  end

  private

  def set_columns
    default_columns = Transaction::DEFAULT_COLUMNS.map { |k| [k, '1'] }.to_h
    @columns = params[:columns] ? params[:columns].to_unsafe_hash : default_columns
  end

  def set_transaction
    @transaction = current_user.transactions.find(params[:id])
  end

  def set_filter
    @filter = Transactions::Model.new(current_user, params[:filter] || {})
  end
end
