require 'rails_helper'

describe Imports::ImportAccount, type: :service do
  let(:connector) { create(:connector) }
  let(:account_params) { build(:account).as_json.symbolize_keys }

  before do
    allow(Imports::ImportTransactions).to receive(:call)
  end

  context 'when account does not exist' do
    it 'creates new account' do
      expect { described_class.new(connector, account_params).call }.to change {
        Account.count
      }.by(1)
    end
  end

  context 'when account exists' do
    let!(:account) { create(:account, connector: connector) }
    let(:account_params) do
      params = account.as_json.symbolize_keys
      params.delete(:id)
      params[:name] = 'new name'
      params
    end

    it 'updates account' do
      expect { described_class.new(connector, account_params).call }.to change {
        Account.count
      }.by(0)
      expect(account.reload.name).to eq('new name')
    end
  end
end
