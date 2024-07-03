class TransactionsController < ApplicationController
  def index
    @transactions = current_user.transactions.order(date: :desc).preload(account: [:connector])
  end
end