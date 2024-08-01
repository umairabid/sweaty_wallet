class TransactionsController < ApplicationController
  def index
    scope = current_user.transactions.preload(account: [:connector])
    @transactions = set_page_and_extract_portion_from scope
  end
end
