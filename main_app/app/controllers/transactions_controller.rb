class TransactionsController < ApplicationController
  def index
    @banks = bank_options
    @categories = categories
    @account_types = account_types
    scope = current_user.transactions.order(date: :desc).preload(account: [:connector])
    @transactions = set_page_and_extract_portion_from scope
  end
end
