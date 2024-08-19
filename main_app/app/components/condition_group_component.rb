class ConditionGroupComponent < ViewComponent::Base
  Condition = Struct.new(:join_by, :type, :value, :edges)

  CONDITION_TYPE_OPTIONS = [["Select Condition", ""]] + ConditionComponent::CONDITION_TYPES.keys.map { |k| [k.to_s.humanize, k] }

  def initialize(group:, references:)
    @references = references
    @group = group || {}
    @new_condition = {}
    @group_id = @group["id"] || 0
  end

  def test_conditions
    Condition.new(nil, :category, 26, [
      Condition.new("and", :category, 27, []),
      Condition.new("or", :group, Condition.new(
        nil, :tags, ["transfer"], [
          Condition.new("and", :transaction_type, "credit", []),
        ]
      ), []),
    ])
  end

  def should_join_next_condition?
    (@group.dig("conditions") || []).size > 0
  end
end
