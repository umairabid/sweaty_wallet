require "rails_helper"

RSpec.describe TransactionFilter, type: :filter do
  let(:user) { create(:user) }
  let(:params) { {} }
  context "when instatiated with empty params" do
    it "does not raise error" do
      expect { described_class.new(user, params) }.to_not raise_error
    end
  end

  context "#apply" do
    let(:subject) { described_class.new(user, params) }
    context "when no params are provided" do
      it "does not raise error" do
        expect { subject.apply(user.transactions) }.to_not raise_error
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
        expect { subject.apply(user.transactions) }.to_not raise_error
      end
    end
  end
end
