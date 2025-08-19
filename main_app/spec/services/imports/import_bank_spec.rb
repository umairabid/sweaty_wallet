require 'rails_helper'

RSpec.describe Imports::ImportBank, type: :service do
  let(:user) { create(:user) }
  let(:params) do
    {
      bank: 'rbc',
      accounts: [
        build(:account).as_json
      ]
    }
  end

  let(:subject) { described_class.new(params, user) }

  describe '#call' do
    before do
      allow(Accounts::ImportAccountJob).to receive(:perform_later)
      allow(GoodJob::Batch).to receive(:enqueue)
    end

    context 'connector does not exist' do
      it 'creates connector' do
        expect { subject.call }.to change { Connector.count }.by(1)
      end
    end

    context 'when connector exists' do
      let!(:connector) { create(:connector, user:, bank: params[:bank]) }

      context 'when account exists' do
        let(:external_id) { '123456789' }
        let!(:account) { create(:account, connector:, external_id:) }

        context 'when account is not included in params' do
          it 'marks account as inactive' do
            expect { subject.call }.to change { account.reload.is_active }.from(true).to(false)
          end
        end
      end
    end
  end
end
