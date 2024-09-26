class TransactionsRepository
  def initialize(base_scope)
    @base_scope = base_scope
  end

  def fetch_by_filters(filter)
    scope = @base_scope.joins(account: :connector).preload(:category)
    if filter.has? :query
      scope = scope.where("description ilike ?", "%#{filter.query}%")
    end

    if filter.has? :bank
      scope = scope.where(accounts: { connectors: { bank: filter.bank } })
    end

    if filter.has? :time_range
      end_date = Time.now.to_date
      start_date = end_date - filter.time_range.to_i.months
      scope = scope.where(date: start_date..end_date)
    end

    if filter.has? :type
      scope = scope.where(is_credit: filter.type == "credit")
    end

    if filter.has? :account_id
      scope = scope.where(account_id: filter.account_id)
    end

    if filter.has? :account_type
      scope = scope.where(account: { account_type: filter.account_type })
    end

    if filter.has? :categories
      categories = filter.categories.select { |id| id.to_i > 0 }
      puts categories.inspect
      if filter.categories.any? { |id| id == "-1" }
        categories << nil
      end
      scope = scope.where(category_id: categories) unless categories.empty?
    end

    scope = scope.order(date: :desc).preload(account: :connector)
  end
end
