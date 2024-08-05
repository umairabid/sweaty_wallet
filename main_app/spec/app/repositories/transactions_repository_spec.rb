require "rails_helper"

RSpec.describe TransactionsRepository, type: :repository do
  let(:user) { create(:user) }
  let(:params) { {} }
  let(:filter) { TransactionFilter.new(user, params) }
  let(:subject) { described_class.new(user.transactions) }

  context "#filter_by_params" do
    context "when no params are provided" do
      it "does not raise error" do
        expect { subject.fetch_by_filters(filter) }.to_not raise_error
      end
    end

    context "when all params are provided" do
      let(:params) {
        {
          query: "abc",
          categories: [1, 2, 3],
          time_range: 1,
          account_type: "credit_card",
          bank: "rbc",
          type: "credit",
          account_id: 2,
        }
      }
      it "does not raise error" do
        expect { subject.fetch_by_filters(filter) }.to_not raise_error
      end
    end
  end
end
