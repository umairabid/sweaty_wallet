class TransactionRules::PersistCondition
  include Callable

  def initialize(transaction_rule, params)
    @transaction_rule = transaction_rule
    @params = params
    @group_id = @params[:group_id]
    @condition = params_to_condition unless @params[:type] == 'group'
    @condition_group = params_to_group if @params[:type] == 'group'
  end

  def call
    if @condition_group.present?
      add_group
    else
      add_to_group
    end
    @transaction_rule.save!
  end

  private

  def add_group
    group = find_group
    raise CustomerError, 'Group not found' if group.blank?

    if @condition_group[:join_by].blank? && group['conditions'].size > 0
      raise CustomerError,
            'Needs join_by'
    end

    group['conditions'] << @condition_group
  end

  def add_to_group
    group = find_group
    raise CustomerError, 'Group not found' if group.blank?

    if @condition[:join_by].blank? && group['conditions'].size > 0
      raise CustomerError,
            'Needs join_by'
    end

    group['conditions'] << @condition
  end

  def find_group(group = nil)
    group ||= @transaction_rule.conditions
    return nil if group['type'] != 'group'
    return group if group['id'] == @group_id

    conditions = group['conditions'] || []
    groups = conditions.map do |c|
      find_group(c)
    end
    groups.compact.first
  end

  def params_to_condition
    type = @params[:type].to_sym
    value = @params[type]
    raise CustomerError, "No value for type #{type}" if value.blank?

    {
      type:,
      value:,
      join_by: @params[:join_by]
    }
  end

  def params_to_group
    {
      id: SecureRandom.uuid,
      type: :group,
      conditions: [],
      join_by: @params[:join_by]
    }
  end
end
