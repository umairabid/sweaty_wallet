require 'rails_helper'

RSpec.describe Transactions::ExportJob, type: :job do
  let(:user) { create(:user) }
  let(:connector) { create(:connector, user: user) }
  let(:account) { create(:account, connector: connector) }
  let!(:transaction) { create(:transaction, account: account) }

  context 'perform' do
    before do
      expect(Transactions::ScopeBuilder).to receive(:call).and_return(user.transactions)
    end
    it 'exports transactions' do
      expect { described_class.perform_now(user) }.to change {
        user.transaction_exports.count
      }.by(1)
    end
  end
end
