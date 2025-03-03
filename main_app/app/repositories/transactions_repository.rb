class TransactionsRepository
  include TimeSeriesable

  def initialize(base_scope)
    @base_scope = base_scope
  end

  def expenses_time_series(start_date, end_date)
    series = for_range_by_day(start_date..end_date).where(is_credit: false)
    accumulate_time_series(series.sum(:amount), start_date, end_date)
  end

  def incomes_time_series(start_date, end_date)
    series = for_range_by_day(start_date..end_date).where(is_credit: true)
    accumulate_time_series(series.sum(:amount), start_date, end_date)
  end

  private

  def for_range_by_day(range)
    @base_scope.where(date: range)
      .where.not(parent_category: { code: "transfers" })
      .left_joins(category: :parent_category)
      .group(:date)
  end
end
