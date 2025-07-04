require 'rails_helper'

RSpec.describe Accounts::Merge do
  let(:user) { create(:user) }
  let(:connector) { create(:connector, user:) }
  let(:target_account) { create(:account_with_transactions, connector:, transactions_count: 5) }
  let(:source_account) do
    create(:account_with_transactions, connector:, transactions_count: 3, external_id: 'xyz')
  end

  let(:subject) { described_class.new(source_account, target_account.id) }

  describe '#call' do
    context 'when source account belongs to the same connector' do
      it 'merges transactions from source account to target account' do
        subject.call
        expect(target_account.reload.transactions.count).to eq(8)
        expect(Account.exists?(source_account.id)).to be_falsey
      end
    end

    context 'when source account does not belong to the same connector' do
      let(:another_connector) { create(:connector, user:) }
      let(:source_account) do
        create(:account_with_transactions, connector: another_connector, transactions_count: 3)
      end

      it 'raises an error' do
        expect { subject.call }.to raise_error(ArgumentError, 'Target account not found')
      end
    end
  end
end
