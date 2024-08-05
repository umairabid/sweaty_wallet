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
  end
end
