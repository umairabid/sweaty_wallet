require "rails_helper"

RSpec.describe Transactions::ExportJob, type: :job do
  let(:user) { create(:user) }
  let(:connector) { create(:connector, user: user) }
  let(:account) { create(:account, connector: connector) }
  let!(:transaction) { create(:transaction, account: account) }

  let(:transaction_filter) { double(TransactionFilter) }
  let(:transactions_repository) { double(TransactionsRepository) }

  context "perform" do
    before do
      expect(transactions_repository).to receive(:fetch_by_filters).with(transaction_filter).and_return(user.transactions)
      expect(TransactionFilter).to receive(:new).and_return(transaction_filter)
      expect(TransactionsRepository).to receive(:new).and_return(transactions_repository)
    end
    it "exports transactions" do
      expect { described_class.perform_later(user) }.to change { user.transaction_exports.count }.by(1)
    end
  end
end
