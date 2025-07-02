class TransactionRules::NextRule
  include Callable

  def initialize(transaction_rule)
    @transaction_rule = transaction_rule
    @user = transaction_rule.user
  end

  def call
    rules = @user.transaction_rules.order(name: :asc, id: :asc)
    current_rule_index = rules.find_index { |rule| rule.id == @transaction_rule.id }
    n = rules.size
    end_index = current_rule_index % n
    index = (current_rule_index + 1) % n
    loop do
      break if index == end_index

      rule = rules[index]
      applier = TransactionRules::ApplyRule.new(rule)
      return rule if applier.preview_count > 0

      # Move to the next index, wrapping around with modulo
      index = (index + 1) % n
    end
  end
end
