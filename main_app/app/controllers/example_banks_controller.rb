class ExampleBanksController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  before_action :set_transactions, only: [:show]

  layout false

  def index
    render :accounts
  end

  def show
    if params[:id] == 'credit'
      render :credit_transactions
    elsif params[:id] == 'debit'
      render :debit_transactions
    end
  end

  private

  def set_transactions
    is_credit = params[:id] == 'credit'
    descriptions = is_credit ? credit_descriptions : debit_descriptions
    dates = ((Date.today - 1.month)..Date.today).to_a
    count = rand(15..20)

    @transactions = count.times.map do |i|
      is_transaction_credit = is_credit ? (i % 4 != 0) : (i % 5 == 0)
      {
        date: dates.sample.strftime('%b %d, %Y'),
        description: descriptions.sample,
        amount: format('%.2f', rand(5.0..500.0)),
        type: is_transaction_credit ? 'credit' : 'debit'
      }
    end.sort_by { |t| Date.parse(t[:date]) }.reverse
  end

  def credit_descriptions
    [
      'Amazon.ca', 'Grocery Store', 'Coffee Shop', 'Gas Station', 'Restaurant',
      'Online Shopping', 'Pharmacy', 'Payment Thank You', 'Department Store',
      'Fast Food', 'Uber Trip', 'Netflix', 'Spotify', 'Gym Membership'
    ]
  end

  def debit_descriptions
    [
      'Payroll Deposit', 'Rent Payment', 'Utilities', 'ATM Withdrawal',
      'Grocery Store', 'Restaurant', 'Coffee Shop', 'Gas Station',
      'E-Transfer', 'Insurance Payment', 'Phone Bill', 'Internet Bill',
      'Deposit Interest', 'Refund', 'Bank Transfer'
    ]
  end
end
