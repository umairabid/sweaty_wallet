class Widgets::TopTransactionsComponent < ViewComponent::Base
  include Widgets::WidgetHelper

  def initialize(user, date)
    @user = user
    @date = date
  end

  def filter
    Transactions::Model.new(
      @user, {
        time_range: start_date..end_date,
        type: 'debit'
      }
    )
  end

  def sorts
    { amount: :desc }
  end
end
