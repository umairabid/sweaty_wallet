require 'rails_helper'

RSpec.describe Seeds::CurrentMonthEmptyDaysTransactions do
  describe '#call' do
    let(:user) { FactoryBot.create(:user) }
    let(:service) { described_class.new(user) }

    context 'when connectors and accounts do not exist' do
      it 'creates a connector and two accounts' do
        expect { service.call }.to change { Connector.count }.by(1)
          .and change { Account.count }.by(2)
      end

      it 'creates transactions for both accounts' do
        expect { service.call }.to change { Transaction.count }.by_at_least(1)
        deposit_account = user.connectors.first.accounts.find_by(account_type: 'deposit_account')
        credit_card_account = user.connectors.first.accounts.find_by(account_type: 'credit_card')
        expect(deposit_account.transactions.count).to be > 0
        expect(credit_card_account.transactions.count).to be > 0
      end
    end

    context 'when connectors and accounts already exist' do
      let!(:connector) { FactoryBot.create(:connector, user: user) }
      let!(:deposit_account) do
        FactoryBot.create(:account, connector: connector, account_type: 'deposit_account')
      end
      let!(:credit_card_account) do
        FactoryBot.create(:account, connector: connector, account_type: 'credit_card')
      end

      it 'does not create additional connectors or accounts' do
        expect { service.call }.not_to(change { Connector.count })
        expect { service.call }.not_to(change { Account.count })
      end

      it 'creates transactions for both existing accounts' do
        expect { service.call }.to change { Transaction.count }.by_at_least(1)
        expect(deposit_account.transactions.count).to be > 0
        expect(credit_card_account.transactions.count).to be > 0
      end
    end
  end
end
