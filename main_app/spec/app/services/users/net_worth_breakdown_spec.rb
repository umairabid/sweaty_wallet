require 'rails_helper'

RSpec.describe Users::NetWorthBreakdown, type: :service do
  let(:user) { create(:user) }
  let(:subject) { described_class.new(user) }
  let(:connector) { create(:connector, user: user) }

  # accounts

  let!(:mortgage) { create(:account, connector:, account_type: :mortgage, balance: 100) }
  let!(:credit_card) { create(:account, connector:, account_type: :credit_card, balance: 150) }
  let!(:deposit) { create(:account, connector:, account_type: :deposit_account, balance: 175) }
  let!(:investment) { create(:account, connector:, account_type: :investment, balance: 200) }
  let!(:credit_line) { create(:account, connector:, account_type: :credit_line, balance: 250) }

  # assets

  let!(:real_estate) { create(:asset, user:, asset_type: :real_estate, value: 300) }
  let!(:car) { create(:asset, user:, asset_type: :vehicle, value: 75) }
  let!(:loan) { create(:asset, user:, asset_type: :loan, value: 50) }

  let(:total_assets) { 175 + 200 + 300 + 75 }
  let(:total_liabilities) { 100 + 150 + 250 + 50 }

  context '#net_worth' do
    it 'returns correct net worth' do
      expect(subject.net_worth).to eq(total_assets - total_liabilities)
    end
  end

  context '#total_assets' do
    it 'returns correct total assets' do
      expect(subject.total_assets).to eq(total_assets)
    end
  end

  context '#total_liabilities' do
    it 'returns correct total liabilities' do
      expect(subject.total_liabilities).to eq(total_liabilities)
    end
  end
end
