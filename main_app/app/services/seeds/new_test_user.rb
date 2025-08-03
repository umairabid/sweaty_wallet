require 'factory_bot_rails'

class Seeds::NewTestUser
  include Callable

  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    User.transaction do
      user = FactoryBot.create(:user, email: @email, password: @password)
      @connector = FactoryBot.create(:connector, user: user)
    end
  end

  private

  def seed_transactions
   Seeds::Transactions.call(credit_card_account, 10, true)
   Seeds::Transactions.call(debit_account, 10, false)
  end

  def credit_card_account
    @credit_card_account ||= FactoryBot.create(:account,
                                               name: 'Credit Card Account',
                                               connector: @connector,
                                               account_type: 'credit_card',
                                               external_id: 'credit_card_external_id',
                                               balance: 432.45)
  end

  def deposit_account
    @deposit_account ||= FactoryBot.create(:account, connector: @connector)
  end
end
