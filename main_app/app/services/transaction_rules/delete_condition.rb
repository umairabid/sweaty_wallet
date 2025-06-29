class TransactionRules::DeleteCondition
  include Callable

  def initialize(transaction_rule, params)
    @transaction_rule = transaction_rule
    @group_id = params[:group_id]
    @index = params[:index].to_i
  end

  def call
    group = find_group
    raise CustomerError, 'Group not found' if group.blank?

    group['conditions'].delete_at(@index)
    if group['conditions'].blank?
      parent = find_parent(@group_id)
      parent['conditions'].delete_at(parent['conditions'].index(group)) if parent.present?
    elsif @index == 0
      group['conditions'][0].delete('join_by')
    end
    @transaction_rule.save!
  end

  private

  def find_group(group = nil)
    group ||= @transaction_rule.conditions
    return nil if group['type'] != 'group'
    return group if group['id'] == @group_id

    conditions = group.dig('conditions') || []
    groups = conditions.map do |c|
      find_group(c)
    end
    groups.compact.first
  end

  def find_parent(group_id, group = nil)
    group ||= @transaction_rule.conditions

    parents = group['conditions']
      .select { |c| c['type'] == 'group' }
      .map do |condition|
      return group if condition['id'] == group_id

      find_parent(group_id, condition)
    end

    parents.compact.first
  end
end
