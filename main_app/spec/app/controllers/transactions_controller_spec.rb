require "rails_helper"

RSpec.describe TransactionsController, type: :controller do
  let(:user) { create(:user) }
  let(:connector) { create(:connector, user: user) }
  let(:account) { create(:account, connector: connector) }
  let(:transactions) { [create(:transaction, account: account)] }

  describe "routes" do
    before do
      sign_in user
    end

    context "get #index" do
      it "performs filter" do
        expect(TransactionFilter).to receive(:new)
        expect(TransactionsRepository).to receive(:new).and_return(double(TransactionsRepository, fetch_by_filters: user.transactions))
        get :index
      end
    end

    context "post #create" do
      let(:transaction) { build(:transaction, account: account) }
      it "creates transaction" do
        expect {
          post :create, params: { transaction: transaction.as_json }
        }.to change { Transaction.count }.by(1)
      end
    end
  end
end
