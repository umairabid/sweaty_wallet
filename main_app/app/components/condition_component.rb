class ConditionComponent < ViewComponent::Base
  with_collection_parameter :condition

  CONDITION_TYPES = {
    category: {
      join_with: "is",
      input_type: "dropdown",
      referencable: :categories,
    },
    tags: {
      placeholder: "Enter comma separated tags",
      join_with: "contains",
      input_type: "text",
    },
    transaction_type: {
      join_with: "is",
      input_type: "dropdown",
      referencable: :transaction_types,
    },
  }

  def initialize(condition:, references:)
    @condition = condition
    @references = references
    @config = CONDITION_TYPES.dig(@condition.type)
  end

  def categories_by_id
    @categories_by_id ||= @references[:categories].map { |p| [p[1], p[0]] }.to_h
  end
end
