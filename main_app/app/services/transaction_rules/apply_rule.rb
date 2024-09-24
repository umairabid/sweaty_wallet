class TransactionRules::ApplyRule
  def initialize(rule)
    @rule = rule
    @arel_table = Transaction.arel_table
    @scope = build_group_query(@rule.conditions)
    @base_scope = @rule.user.transactions
  end

  def preview
    @base_scope.where(@scope)
  end

  def apply
  end

  private

  def build_group_query(group)
    first_condition = nil
    group["conditions"].each do |condition|
      built_condition = condition["type"] == "group" ? build_group_query(condition) : build_condition(condition)
      join_by = condition["join_by"]

      if join_by.blank?
        first_condition = built_condition
      elsif join_by == "or"
        first_condition = first_condition.or(built_condition)
      elsif join_by == "and"
        first_condition = first_condition.and(built_condition)
      else
        raise "Unsupported join type: #{join_by}"
      end
    end
    @arel_table.grouping(first_condition)
  end

  def build_condition(condition)
    column = condition["type"]
    value = condition["value"]

    case column
    when "category_id"
      @arel_table[:category_id].eq(value)
    when "tags"
      tags = value.split(",").map(&:strip)
      conditions = tags.map do |tag|
        @arel_table[:description].matches("%#{tag}%", nil)
      end
      conditions.reduce { |acc, condition| acc.and(condition) }
    when "type"
      @arel_table[:is_credit].eq(value == "credit")
    else
      raise "Unsupported condition type: #{column}"
    end
  end
end
