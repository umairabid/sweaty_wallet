class Widgets::TopTransactionsComponent < ViewComponent::Base
  include Widgets::WidgetHelper

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
end
