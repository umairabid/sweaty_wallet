class TransactionsRepository
  include Concerns::TimeSeriesable

  def initialize(base_scope)
    @base_scope = base_scope
  end

  def expenses_time_series(start_date, end_date)
    series = @base_scope.where(date: start_date..end_date, is_credit: false)
      .where.not(category: { code: "transfer" })
      .left_joins(:category)
      .group(:date).sum(:amount)
    accumulate_time_series(series, start_date, end_date)
  end

  def incomes_time_series(start_date, end_date)
    series = @base_scope.where(date: start_date..end_date).where(is_credit: true).group(:date).sum(:amount)
    accumulate_time_series(series, start_date, end_date)
  end
end
