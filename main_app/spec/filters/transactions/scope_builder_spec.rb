require 'rails_helper'

RSpec.describe Transactions::ScopeBuilder do
  let(:user) { create(:user) }
  let(:params) do
    {
      query: 'abc',
      categories: [1, 2, 3],
      time_range: 'this_month',
      account_type: 'credit_card',
      bank: 'rbc',
      type: 'credit',
      account_id: 2
    }
  end
  let(:filter_model) { Transactions::Model.new(user, params) }

  let(:subject) { described_class.new(filter_model, Transaction.all) }

  context 'when all params are provided' do
    it 'does not raise error' do
      expect { subject.call }.to_not raise_error
    end
  end
end
