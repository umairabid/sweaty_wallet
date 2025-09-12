require 'factory_bot_rails'

class Seeds::CurrentMonthEmptyDaysTransactions
  include Callable

  def initialize(user)
    @user = user
  end

  def call
    Seeds::Transactions.call(deposit_account, deposite_account_transactions_count, dates: dates)
    Seeds::Transactions.call(credit_card_account, credit_card_account_transactions_count,
      is_credit: true, dates: dates)
  end

  private

  def deposite_account_transactions_count
    (dates.count * rand(0.7..1.1)).to_i
  end

  def credit_card_account_transactions_count
    (dates.count * rand(1.1..1.7)).to_i
  end

  def dates
    (start_date..current_date).to_a
  end

  def current_month_start_date
    current_date.beginning_of_month
  end

  def current_date
    Time.zone.now.to_date
  end

  def start_date
    last_transaction ? last_transaction.date + 1 : current_month_start_date
  end

  def last_transaction
    @user.transactions.where(date: current_month_start_date..current_date).order(date: :desc).first
  end

  def connector
    @connector ||= @user.connectors.first || FactoryBot.create(:connector, user: @user)
  end

  def deposit_account
    @deposit_account ||= connector.accounts.where(account_type: 'deposit_account').first ||
                         FactoryBot.create(:account, connector: connector)
  end

  def credit_card_account
    @credit_card_account ||= connector.accounts.where(account_type: 'credit_card').first ||
                             FactoryBot.create(:account, connector: connector,
                               account_type: 'credit_card')
  end
end
