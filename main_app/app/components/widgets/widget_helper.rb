module Widgets::WidgetHelper
  extend ActiveSupport::Concern

  def initialize(user, date)
    @user = user
    @date = date
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
