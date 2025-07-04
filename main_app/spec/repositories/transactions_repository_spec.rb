require "rails_helper"

RSpec.describe TransactionsRepository, type: :repository do
  let(:user) { create(:user) }
  let(:connector) { create(:connector, user: user) }
  let(:parent_category) { create(:category, user: user) }
  let(:cat) { create(:category, user: user, parent_category: parent_category) }
  let(:account) { create(:account, connector: connector) }
  let(:subject) { described_class.new(user.transactions) }

  describe "#expenses_time_series" do
    context "when multiple transactions on day" do
      let(:start_of_month) { Time.zone.now.to_date.beginning_of_month }
      let(:date) { start_of_month + 3.day }
      let(:end_of_month) { Time.zone.now.to_date.end_of_month }
      let!(:transactions) { create_list(:transaction, 3, account: account, date: date, is_credit: false, category: cat) }

      it "returns sum of transactions for day" do
        series = subject.expenses_time_series(start_of_month, end_of_month)
        expect(series[date]).to eq(transactions.sum(&:amount))
      end

      it "returns sum of transactions for previous day" do
        series = subject.expenses_time_series(start_of_month, end_of_month)
        expect(series[date + 1]).to eq(transactions.sum(&:amount))
      end

      context "when transaction exists on another day" do
        let(:another_date) { start_of_month + 10.day }
        let!(:another_transaction) { create(:transaction, account: account, date: another_date, is_credit: false, category: cat) }

        it "returns sum of transactions for day" do
          series = subject.expenses_time_series(start_of_month, end_of_month)
          expect(series[another_date]).to eq(another_transaction.amount + transactions.sum(&:amount))
        end
      end
    end
  end
end
