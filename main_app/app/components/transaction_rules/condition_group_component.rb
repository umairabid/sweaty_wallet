class TransactionRules::ConditionGroupComponent < ViewComponent::Base
  Condition = Struct.new(:join_by, :type, :value, :edges)

  CONDITION_TYPE_OPTIONS = [["Select Condition", ""]] + TransactionRules::ConditionComponent::CONDITION_TYPES.keys.map { |k| [k.to_s.humanize, k] }

  def initialize(group:, references:, level: 0)
    @references = references
    @group = group || {}
    @new_condition = {}
    @group_id = @group["id"] || 0
    @level = level
  end

  def condition_options
    all_conditions = TransactionRules::ConditionComponent::CONDITION_TYPES.keys.map { |k| [k.to_s.humanize, k] }
    if @group["id"].blank? || @level > 0
      all_conditions = all_conditions.select { |k| k[1] != :group }
    end
    [["Select Condition", ""]] + all_conditions
  end

  def should_join_next_condition?
    (@group.dig("conditions") || []).size > 0
  end
end
