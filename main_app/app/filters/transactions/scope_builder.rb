class Transactions::ScopeBuilder
  include Callable

  delegate :has?, to: :@filter_model
  delegate(*Transactions::Model::ATTRIBUTES, to: :@filter_model)

  def initialize(filter_model, base_scope)
    @filter_model = filter_model
    @base_scope = base_scope
  end

  def call
    scope = @base_scope.joins(account: :connector).preload(:category)
    scope = scope.where('description ilike ?', "%#{query}%") if has? :query

    scope = scope.where(accounts: { connector_id: bank }) if has? :bank

    if has? :time_range
      end_date = Time.now.to_date
      start_date = end_date - time_range.to_i.months
      scope = scope.where(date: start_date..end_date)
    end

    scope = scope.where(is_credit: type == 'credit') if has? :type

    scope = scope.where(account_id:) if has? :account_id

    scope = scope.where(account: { account_type: }) if has? :account_type

    if has? :categories
      cats = categories.select { |id| id.to_i > 0 }
      cats << nil if categories.any? { |id| id == '-1' }
      scope = scope.where(category_id: cats) unless cats.empty?
    end

    if has? :show_duplicates
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
      duplicate_ids = Transaction.unscoped.select('id').from(
        scope.select(from_sql)
      ).where('duplicate_count > ?', 1).to_a.map(&:id)

      # Filter the original scope to include only duplicates
      scope = scope.where(id: duplicate_ids)
    end

    scope = rule_applier.preview if has? :transaction_rule_id

    scope.order(date: :desc).preload(account: :connector)
  end

  private

  def rule_applier
    @rule_applier ||= begin
      rule = TransactionRule.find @filter_model.transaction_rule_id
      TransactionRules::ApplyRule.new(rule)
    end
  end
end
