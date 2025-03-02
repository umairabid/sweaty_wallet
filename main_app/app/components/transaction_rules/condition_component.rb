class TransactionRules::ConditionComponent < ViewComponent::Base
  with_collection_parameter :condition

  CONDITION_TYPES = {
    category_id: {
      join_with: "is",
    },
    tags: {
      join_with: "contains",
    },
    transaction_type: {
      join_with: "is",
    },
    bank_account_id: {
      join_with: "is",
    },
    amount: {
      join_with: "is",
    },
    group: {},
  }

  def initialize(group_id:, index:, condition:, references:)
    @condition = condition
    @references = references
    @group_id = group_id
    @index = index
    @config = CONDITION_TYPES.dig(@condition["type"].to_sym) if @condition.present?
  end

  def render?
    @condition.present?
  end

  def categories_by_id
    @categories_by_id ||= @references[:categories].map { |p| [p[1], p[0]] }.to_h
  end
end
