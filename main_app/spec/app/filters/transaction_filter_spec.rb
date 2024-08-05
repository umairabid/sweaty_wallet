require "rails_helper"

RSpec.describe TransactionFilter, type: :filter do
  let(:user) { create(:user) }
  context "when instatiated with empty params" do
    let(:params) { {} }
    it "does not raise error" do
      expect { described_class.new(user, params) }.to_not raise_error
    end
  end
end
