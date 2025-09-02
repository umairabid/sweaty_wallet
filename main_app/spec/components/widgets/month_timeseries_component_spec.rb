require 'rails_helper'

RSpec.describe Widgets::MonthTimeseriesComponent, type: :repository do
  let(:user) { create(:user) }
  let(:connector) { create(:connector, user: user) }
  let(:parent_category) { create(:category, user: user) }
  let(:cat) { create(:category, user: user, parent_category: parent_category) }
  let(:account) { create(:account, connector: connector) }
  let(:subject) { described_class.new(user, date) }
  let(:start_of_month) { Time.zone.now.to_date.beginning_of_month }
  let(:date) { start_of_month + 3.day }
  let(:end_of_month) { Time.zone.now.to_date.end_of_month }
  let!(:transactions) do
    create_list(:transaction, 3, account: account, date: date, is_credit: false, category: cat)
  end

  describe '#expenses_time_series' do
    context 'when multiple transactions on day' do

      it 'returns sum of transactions for day' do
        data = subject.data
        series = data[0][:data]
        expect(series[date]).to eq(transactions.sum(&:amount))
      end

      it 'returns sum of transactions for previous day' do
        data = subject.data
        series = data[0][:data]
        expect(series[date + 1]).to eq(transactions.sum(&:amount))
      end

      context 'when transaction exists on another day' do
        let(:another_date) { start_of_month + 10.day }
        let!(:another_transaction) do
          create(:transaction, account: account, date: another_date, is_credit: false,
                 category: cat)
        end

        it 'returns sum of transactions for day' do
          data = subject.data
          series = data[0][:data]
          expect(series[another_date]).to eq(another_transaction.amount + transactions.sum(&:amount))
        end
      end
    end
  end
end

