require 'rails_helper'

RSpec.describe TransactionsRepository, type: :repository do
  let(:user) { create(:user) }
  let(:connector) { create(:connector, user: user) }
  let(:parent_category) { create(:category, user: user) }
  let(:cat) { create(:category, user: user, parent_category: parent_category) }
  let(:account) { create(:account, connector: connector) }
  let(:subject) { described_class.new(user.transactions) }
  let(:start_of_month) { Time.zone.now.to_date.beginning_of_month }
  let(:date) { start_of_month + 3.day }
  let(:end_of_month) { Time.zone.now.to_date.end_of_month }
  let!(:transactions) do
    create_list(:transaction, 3, account: account, date: date, is_credit: false, category: cat)
  end

  describe '#for_range_by_day' do
    it 'returns transactions for the given range' do
      expect(subject.for_range_by_day(start_of_month..end_of_month).select(:date).count).to eq({ date => 3 })
    end
  end

  describe '#for_range' do
    it 'returns transactions for the given range' do
      expect(subject.for_range(start_of_month..end_of_month)).to match_array(transactions)
    end
  end

  describe '#top_transactions' do
    it 'returns transactions for the given range' do
      expect(subject.top_transactions(start_of_month..end_of_month)).to match_array(transactions)
    end
  end
end
