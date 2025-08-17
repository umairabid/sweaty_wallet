require 'rails_helper'

RSpec.describe Transactions::SetSuggestedCategories, type: :service do
  let(:user) { create(:user) }
  let(:connector) { create(:connector, user: user) }
  let(:account) { create(:account, connector: connector) }
  let(:transaction) do
    transaction = create(:transaction, account: account)
    transaction.to_neighbors << create(:transaction, account: account,
      category: user.categories.sample)
    transaction.to_neighbors << create(:transaction, account: account,
      category: user.categories.sample)
    transaction.to_neighbors << create(:transaction, account: account,
      category: user.categories.sample)
    transaction.save!
    transaction
  end
  let(:transaction_ids) { [transaction.id] }
  let(:service) { Transactions::SetSuggestedCategories.new(user, transaction_ids) }
  let(:suggested_category) { user.categories.sample }

  before do
    expect(RubyLLM).to receive_message_chain(:chat, :with_params, :ask, :content)
      .and_return([{ id: transaction.id, category: suggested_category.code }].to_json)
  end

  context 'when suggestions are provided' do
    it 'sets suggested categories' do
      service.call
      expect(transaction.reload.suggested_category_id).to eq(suggested_category.id)
    end
  end
end
