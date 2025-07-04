require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  let(:user) { create(:user) }
  let(:connector) { create(:connector, user: user) }
  let(:account) { create(:account, connector: connector) }
  let(:transactions) { [create(:transaction, account: account)] }

  describe 'routes' do
    before do
      sign_in user
    end

    context 'get #index' do
      it 'performs filter' do
        expect(Transactions::Model).to receive(:new)
        get :index
      end
    end

    context 'post #create' do
      let(:transaction) { build(:transaction, account: account) }
      it 'creates transaction' do
        expect do
          post :create, params: { transaction: transaction.as_json }
        end.to change { Transaction.count }.by(1)
      end
    end
  end
end
