class TransactionsRepository

  def initialize(base_scope)
    @base_scope = base_scope.preload(:category)
  end

  def top_transactions(start_date, end_date)
    @base_scope.where(date: start_date..end_date)
      .exclude_transfers
      .order(amount: :desc)
  end

  def for_range(start_date, end_date)
    @base_scope
      .where(date: start_date..end_date)
      .exclude_transfers
  end

  def top_categories(start_date, end_date)
    @base_scope
      .select('category_id, sum(amount) as cat_amount')
      .where(date: start_date..end_date, is_credit: false)
      .exclude_transfers
      .group(:category_id)
      .order(cat_amount: :desc)
  end

  def primary_by_range(range)
    @base_scope
      .where(date: range)
      .exclude_transfers
  end

  def for_range_by_day(range)
    @base_scope
      .exclude_transfers
      .where(date: range)
      .group(:date)
  end
end
