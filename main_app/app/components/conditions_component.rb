class ConditionsComponent < ViewComponent::Base
  Condition = Struct.new(:join_by, :type, :value, :edges)

  def initialize(conditions:, references:)
    @references = references
    @conditions = conditions
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

  def render?
    @conditions.present?
  end
end
