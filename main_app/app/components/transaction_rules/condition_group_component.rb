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
    all_conditions = TransactionRules::ConditionComponent::CONDITION_TYPES.keys
      .select { |k| @level.zero? || k != :group }
      .map do |k|
      [k.to_s.humanize, k]
    end
    [['Select Condition', '']] + all_conditions
  end

  def should_join_next_condition?
    (@group['conditions'] || []).size.positive?
  end

  def component_class
    return if @level.zero?

    'space-y-3 rounded-lg border bg-card text-card-foreground shadow-sm border-l-4 border-l-orange-500 bg-orange-50/30 mt-4 p-4'
  end
end
