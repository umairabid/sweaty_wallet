require 'factory_bot_rails'

class Seeds::TransactionRules
  include Callable

  def initialize(user)
    @user = user
  end

  def call
    create_eating_out_rule!
    create_groceries_rule!
  end

  private

  def create_eating_out_rule!
    FactoryBot.create(
      :transaction_rule,
      user: @user,
      name: 'Eating Out',
      category: @user.categories.find_by(code: 'restaurants'),
      conditions: {
        'id' => SecureRandom.uuid, 'type' => 'group', 'conditions' => [
          { 'type' => 'tags', 'value' => 'DOMINOS PIZZA', 'join_by' => nil },
          { 'type' => 'tags', 'value' => 'DD/DOORDASHNANDOSPERIP', 'join_by' => 'or' },
          { 'type' => 'tags', 'value' => 'DD/DOORDASHDHALIWALSWE', 'join_by' => 'or' }
        ]
      }
    )
  end

  def create_groceries_rule!
    FactoryBot.create(
      :transaction_rule,
      user: @user,
      name: 'Groceries',
      category: @user.categories.find_by(code: 'groceries'),
      conditions: {
        'id' => SecureRandom.uuid,
        'type' => 'group',
        'conditions' => [
          {
            'id' => SecureRandom.uuid,
            'type' => 'group', 'join_by' => nil, 'conditions' => [
              { 'type' => 'tags', 'value' => 'walmart', 'join_by' => nil },
              { 'type' => 'tags', 'value' => 'freshco', 'join_by' => 'or' },
              { 'type' => 'tags', 'value' => 'costco', 'join_by' => 'or' }
            ]
          },
          {
            'id' => SecureRandom.uuid, 'type' => 'group', 'join_by' => 'and',
            'conditions' => [
              { 'type' => 'transaction_type', 'value' => 'debit', 'join_by' => nil },
              {
                'type' => 'bank_account_id',
                'value' => @user.accounts.where(account_type: 'deposit_account').first.id.to_s,
                'join_by' => 'and'
              }
            ]
          }
        ]
      }
    )
  end
end
