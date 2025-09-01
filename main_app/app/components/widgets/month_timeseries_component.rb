class Widgets::MonthTimeseriesComponent < ViewComponent::Base
  include Widgets::WidgetHelper

  def dates
    (start_date..end_date).to_a.to_json
  end

  def data
    [
      {
        name: 'Expenses',
        data: expenses_time_series,
        color: '#ef4444'
      },
      {
        name: 'Incomes',
        data: incomes_time_series
      }
    ]
  end

  def options
    {
      options: {
        smooth: true,
        color: ['#ef4444', '#22c55e'],
        grid: {
          top: 0,
          right: 0,
          bottom: 0,
          left: 0,
          containLabel: false
        }
      }
    }
  end

  private

  def expenses_time_series
    series = transactions_repo.for_range_by_day(start_date..end_date).where(is_credit: false)
    accumulate_time_series(series.sum(:amount))
  end

  def incomes_time_series
    series = transactions_repo.for_range_by_day(start_date..end_date).where(is_credit: true)
    accumulate_time_series(series.sum(:amount))
  end
end
