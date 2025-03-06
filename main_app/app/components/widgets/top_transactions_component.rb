class Widgets::TopTransactionsComponent < ViewComponent::Base
  def initialize(user, date, credit)
    @user = user
    @date = date
    @credit = credit
  end

  def transactions
    @transactions ||= transactions_repo
      .top_transactions(start_date, end_date)
      .where(is_credit: @credit).limit(10)
  end

  def render?
    transactions.present?
  end

  private

  def start_date
    @date.beginning_of_month
  end

  def end_date
    @date.end_of_month
  end

  def transactions_repo
    @transactions_repo ||= TransactionsRepository.new(@user.transactions)
  end
end
