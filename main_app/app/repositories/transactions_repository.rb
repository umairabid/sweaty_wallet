class TransactionsRepository

  def initialize(base_scope)
    @base_scope = base_scope.preload(:category)
  end

  def top_transactions(range)
    for_range(range)
      .order(amount: :desc)
  end

  def top_categories(range)
    for_range(range)
      .select('category_id, sum(amount) as cat_amount')
      .group(:category_id)
      .order(cat_amount: :desc)
  end
  
  def for_range(range)
    @base_scope
      .exclude_transfers
      .where(date: range)
  end

  def for_range_by_day(range)
    @base_scope
      .exclude_transfers
      .where(date: range)
      .group(:date)
  end
end
