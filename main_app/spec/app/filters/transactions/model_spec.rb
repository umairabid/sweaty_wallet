require 'rails_helper'

RSpec.describe Transactions::Model, type: :filter do
  let(:user) { create(:user) }
  let(:params) { {} }
  context 'when instantiated with empty params' do
    it 'does not raise error' do
      expect { described_class.new(user, params) }.to_not raise_error
    end
  end
end
