class Widgets::MonthTimeseriesComponent < ViewComponent::Base
  def initialize(user, date)
    @user = user
    @date = date
  end

  def dates
    (start_date..end_date).to_a.to_json
  end

  def expenses
    transactions_repo.expenses_time_series(start_date, end_date).values.to_json
  end

  def incomes
    transactions_repo.incomes_time_series(start_date, end_date).values.to_json
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
