class Transactions::ScopeBuilder
  include Callable

  TIME_RANGES = {
    'this_month' => 1,
    'last_month' => 2,
    'thirty_days' => 30,
    'sixty_days' => 60,
    'ninety_days' => 90
  }.freeze

  delegate :has?, to: :@filter_model
  delegate(*Transactions::Model::ATTRIBUTES, to: :@filter_model)

  def initialize(filter_model, base_scope)
    @filter_model = filter_model
    @base_scope = base_scope
    @scope = @base_scope.joins(account: :connector).preload(:category)
  end

  def call
    @scope = @scope.where('description ilike ?', "%#{query}%") if has? :query
    @scope = @scope.where(accounts: { connector_id: bank }) if has? :bank
    @scope = @scope.where(is_credit: type == 'credit') if has? :type
    @scope = @scope.where(account_id:) if has? :account_id
    @scope = @scope.where(account: { account_type: }) if has? :account_type
    @scope = rule_applier.preview if has? :transaction_rule_id
    @scope = @scope.order(date: :desc, id: :asc).preload(account: :connector)

    add_time_range if has? :time_range
    add_categories if has? :categories
    add_duplicates if has? :show_duplicates

    @scope
  end

  private

  def add_duplicates
    from_sql = <<~SQL
      transactions.*,#{' '}
      COUNT(transactions.*) OVER (
        PARTITION BY date,#{' '}
        TRIM(REGEXP_REPLACE(description, '\\s+', ' ', 'g')),#{' '}
        amount,#{' '}
        is_credit,#{' '}
        account_id
      ) as duplicate_count
    SQL
    duplicate_ids = Transaction.select('id').from(
      @base_scope.select(from_sql)
    ).where('duplicate_count > ?', 1).to_a.map(&:id)

    @scope = @scope.where(id: duplicate_ids)
  end

  def add_categories
    cats = categories.select { |id| id.to_i.positive? }
    cats << nil if categories.any? { |id| id == '-1' }
    @scope = @scope.where(category_id: cats) unless cats.empty?
  end

  def add_time_range
    if monthly?
      add_month_range
    else
      add_days_range
    end
  end

  def add_month_range
    month_range = TIME_RANGES[time_range]
    today = Time.now.to_date
    start_of_month = today.beginning_of_month - (month_range.to_i - 1).months
    end_date = start_of_month.end_of_month
    @scope = @scope.where(date: start_of_month..end_date)
  end

  def add_days_range
    days_range = TIME_RANGES[time_range]
    end_date = Time.now.to_date
    start_date = end_date - (days_range.days)
    @scope = @scope.where(date: start_date..end_date)
  end

  def monthly?
    %w[this_month last_month].include?(time_range)
  end

  def rule_applier
    @rule_applier ||= begin
      rule = TransactionRule.find @filter_model.transaction_rule_id
      TransactionRules::ApplyRule.new(rule, @scope)
    end
  end
end
