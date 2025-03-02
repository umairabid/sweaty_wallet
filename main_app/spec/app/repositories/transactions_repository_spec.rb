require "rails_helper"

RSpec.describe TransactionsRepository, type: :repository do
  let(:user) { create(:user) }
  let(:subject) { described_class.new(user.transactions) }
end
