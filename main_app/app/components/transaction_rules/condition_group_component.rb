class TransactionRules::ConditionGroupComponent < ViewComponent::Base
  Condition = Struct.new(:join_by, :type, :value, :edges)

  def initialize(group:, references:, level: 0)
    @references = references
    @group = group
    @new_condition = {}
    @group_id = @group['id']
    @level = level
  end

  def condition_options
    all_conditions = TransactionRules::ConditionComponent::CONDITION_TYPES.keys.map do |k|
      [k.to_s.humanize, k]
    end
    [['Select Condition', '']] + all_conditions
  end

  def should_join_next_condition?
    (@group['conditions'] || []).size.positive?
  end
end
