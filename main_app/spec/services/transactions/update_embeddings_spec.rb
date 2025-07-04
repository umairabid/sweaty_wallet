require 'rails_helper'

RSpec.describe Transactions::UpdateEmbeddings, type: :service do
  let(:user) { create(:user) }
  let(:connector) { create(:connector, user: user) }
  let(:account) { create(:account, connector: connector) }
  let(:category) { create(:category, user: user) }
  let(:transactions) do
    [
      create(:transaction, account: account, description: 'foo', category: category),
      create(:transaction, account: account, description: 'bar', category: category),
      create(:transaction, account: account, description: 'baz', category: category)
    ]
  end
  let(:service) { described_class.new(transactions) }
  let(:vectors) do
    [
      Transaction::DIMENSION_COUNT.times.map { |i| i * 1 },
      Transaction::DIMENSION_COUNT.times.map { |i| i * 2 },
      Transaction::DIMENSION_COUNT.times.map { |i| i * 3 }
    ]
  end

  describe '#call' do
    before do
      allow(RubyLLM).to receive(:embed).and_return(double(vectors: vectors))
    end
    it 'updates embeddings' do
      service.call

      transactions.all? { |t| t.embedding.present? }
    end
  end
end
