class TransactionRules::PersistCondition
  include Callable

  def initialize(transaction_rule, params)
    @transaction_rule = transaction_rule
    @group_id = params[:group_id]
    @condition = params_to_condition(params) unless params[:type] == "group"
    @nested_group = params_to_group(params) if params[:type] == "group"
  end

  def call
    if @transaction_rule.conditions.blank?
      initialize_conditions
    elsif @nested_group.present?
      add_nested_group
    else
      add_to_group
    end
    @transaction_rule.save!
  end

  private

  def initialize_conditions
    @transaction_rule.conditions = {
      id: SecureRandom.uuid,
      type: :group,
      conditions: [@condition],
    }
  end

  def add_nested_group
    group = find_group
    raise CustomerError, "Group not found" if group.blank?
    raise CustomerError, "Needs join_by" if @nested_group[:join_by].blank? && group["conditions"].size > 0

    group["conditions"] << @nested_group
  end

  def add_to_group
    group = find_group
    raise CustomerError, "Group not found" if group.blank?
    raise CustomerError, "Needs join_by" if @condition[:join_by].blank? && group["conditions"].size > 0

    group["conditions"] << @condition
  end

  def find_group(group = nil)
    group ||= @transaction_rule.conditions
    return nil if group["type"] != 'group'
    return group if group["id"] == @group_id

    conditions = group.dig("conditions") || []
    groups = conditions.map do |c|
      find_group(c)
    end
    groups.compact.first
  end

  def params_to_condition(params)
    type = params[:type].to_sym
    value = params[type]
    raise CustomerError, "No value for type #{type}" if value.blank?

    {
      type: type,
      value: value,
      join_by: params.dig(:join_by),
    }
  end

  def params_to_group(params)
    {
      id: SecureRandom.uuid,
      type: :group,
      conditions: [],
      join_by: params.dig(:join_by),
    }
  end
end
