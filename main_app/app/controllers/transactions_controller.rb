class TransactionsController < ApplicationController
  before_action :set_filter, only: %i[index]
  before_action :set_repository, only: %i[index]

  def index
    scope = @repo.fetch_by_filters @filter
    @transactions = set_page_and_extract_portion_from scope
  end

  private

  def set_filter
    @filter = TransactionFilter.new(current_user, params[:filter] || {})
  end

  def set_repository
    @repo = TransactionsRepository.new(current_user.transactions)
  end
end
