class TransactionRules::ApplyRule
  def initialize(rule)
    @rule = rule
    @arel_table = Transaction.arel_table
    @rules_scope = build_group_query(@rule.conditions)
    @category_scope = @arel_table.grouping(@arel_table[:category_id].not_eq(@rule.category_id).or(@arel_table[:category_id].eq(nil)))
  end

  def preview_count
    preview.count
  end

  def preview
    @rule.user.transactions.where((@category_scope).and(@rules_scope))
  end

  def apply
    preview.update_all(category_id: @rule.category_id)
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
    when "transaction_type"
      @arel_table[:is_credit].eq(value == "credit")
    when "bank_account_id"
      @arel_table[:account_id].eq(value)
    when "amount"
      @arel_table[:amount].eq(value)
    else
      raise "Unsupported condition type: #{column}"
    end
  end
end
