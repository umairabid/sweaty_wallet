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
  
  def accumulate_time_series(series)
    (start_date..end_date).each_with_object({}) do |date, hash|
      hash[date] = (series[date] || 0) + (hash[date - 1] || 0)
    end
  end
end
