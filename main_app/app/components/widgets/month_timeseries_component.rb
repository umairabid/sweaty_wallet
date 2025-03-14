class Widgets::MonthTimeseriesComponent < ViewComponent::Base
  include Widgets::WidgetHelper

  def dates
    (start_date..end_date).to_a.to_json
  end

  def expenses
    transactions_repo.expenses_time_series(start_date, end_date).values.to_json
  end

  def incomes
    transactions_repo.incomes_time_series(start_date, end_date).values.to_json
  end
end
