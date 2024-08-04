class TransactionsController < ApplicationController
  include UserSelects

  before_action :set_filter_options, only: %i[index]

  def index
    puts params[:filter].inspect
    scope = current_user.transactions.order(date: :desc).preload(account: [:connector])
    @transactions = set_page_and_extract_portion_from scope
  end

  private

  def set_filter_options
    @banks = [["Select Bank", ""]] + bank_options
    @categories = [["Select Category", ""]] + categories
    @account_types = [["Select Account", ""]] + account_types
    @time_ranges = [["Select Duration", ""], ["Last Month", 1], ["Last Two Months", 2], ["Last Three Months", 3]]
    @types = [["Select Type", ""], ["Credit", "credit"], ["Debit", "debit"]]
  end
end
