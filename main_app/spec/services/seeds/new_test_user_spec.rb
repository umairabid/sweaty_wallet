require 'rails_helper'

RSpec.describe Seeds::NewTestUser do
  let(:email) { 'q2h0t@example.com' }
  let(:password) { 'password' }

  let(:subject) { described_class.new(email, password) }

  describe '#call' do
    it 'creates a user' do
      expect { subject.call }.to change { User.count }.by(1)
    end
  end
end
