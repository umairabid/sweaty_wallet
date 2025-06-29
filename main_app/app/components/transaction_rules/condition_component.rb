class TransactionRules::ConditionComponent < ViewComponent::Base
  with_collection_parameter :condition

  CONDITION_TYPES = {
    category_id: {
      join_with: 'is'
    },
    tags: {
      join_with: 'contains'
    },
    transaction_type: {
      join_with: 'is'
    },
    bank_account_id: {
      join_with: 'is'
    },
    amount: {
      join_with: 'is'
    },
    group: {}
  }.freeze

  def initialize(group_id:, index:, condition:, references:)
    @condition = condition
    @references = references
    @group_id = group_id
    @index = index
    @config = CONDITION_TYPES[@condition['type'].to_sym] if @condition.present?
  end

  def render?
    @condition.present?
  end

  def categories_by_id
    @categories_by_id ||= @references[:categories].map { |p| [p[1].to_s, p[0]] }.to_h
  end

  def accounts_by_id
    @accounts_by_id ||= @references[:accounts].map { |p| [p[1].to_s, p[0]] }.to_h
  end
end
