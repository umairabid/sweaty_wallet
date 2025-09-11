require 'rails_helper'

RSpec.describe Transactions::ScopeBuilder do

  let(:user) { create(:user) }
  let(:bank) { 'rbc' }
  let(:connector) { create(:connector, user:, bank:) }
  let(:account) { create(:account, connector:, account_type: 'credit_card') }
  let(:category) { create(:category, user:) }
  let(:base_scope) { Transaction.all }
  let(:params) do
    {
      query: 'abc',
      categories: [1, 2, 3],
      account_type: 'credit_card',
      bank: 'rbc',
      type: 'credit',
      account_id: 2
    }
  end
  let(:filter_model) { Transactions::Model.new(user, params) }

  let(:subject) { described_class.new(filter_model, base_scope) }

  context 'when all params are provided' do
    it 'does not raise error' do
      expect { subject.call }.to_not raise_error
    end
  end

  context 'when show duplicates is true' do
    let(:params) { { show_duplicates: '1' } }
    let!(:t1) { create(:transaction, account:, category:, is_credit: true) }
    let!(:t2) { create(:transaction, account:, category:, is_credit: true, description: t1.description, amount: t1.amount) }


    it 'returns duplicate transactions' do
      result = subject.call
      expect(result.count).to eq 2
    end

    context 'when other transaction has different amount' do
      let!(:t3) { create(:transaction, account:, category:, is_credit: true, description: t1.description, amount: 100) }

      it 'does not return different transaction' do
        result = subject.call
        transaction_ids = result.map(&:id)
        expect(transaction_ids).to match_array [t1.id, t2.id]
      end
    end

    context 'when other transaction has same description but with extra spaces' do
      let!(:t3) { create(:transaction, account:, category:, is_credit: true, description: "  #{t1.description}  ", amount: t1.amount) }

      it 'does return transaction as duplicate' do
        result = subject.call
        transaction_ids = result.map(&:id)
        expect(transaction_ids).to match_array [t1.id, t2.id, t3.id]
      end
    end
  end

  context 'when filtering by time range' do
    let(:params) { { time_range: time_range } }
    let(:now) { Time.zone.now.to_date }

    context 'when time range time is days' do
      let(:time_range) { 'thirty_days' }
      let!(:t1) { create(:transaction, account:, category:, is_credit: true, date: now - 1.day) }
      let!(:t2) { create(:transaction, account:, category:, is_credit: true, date: now - 32.days) }

      it 'returns transactions for last 30 days' do
        result = subject.call
        expect(result.first.id).to eq t1.id
      end
    end

    context 'when time range is monthly' do
      let!(:t1) { create(:transaction, account:, category:, is_credit: true, date: now) }
      let!(:t2) { create(:transaction, account:, category:, is_credit: true, date: now - 1.month) }

      context 'when time range is this month' do
        let(:time_range) { 'this_month' }

        it 'returns transactions for last month' do
          result = subject.call
          expect(result.first.id).to eq t1.id
        end
      end

      context 'when time range is last month' do
        let(:time_range) { 'last_month' }

        it 'returns transactions for last month' do
          result = subject.call
          expect(result.first.id).to eq t2.id
        end
      end
    end
  end

  context 'when applying a rule' do
    let(:rule) { instance_double(TransactionRule, id: 1) }
    let(:params) { { transaction_rule_id: 1 } }
    let(:applier) { instance_double(TransactionRules::ApplyRule, preview: base_scope) }
    
    before do
      allow(TransactionRule).to receive(:find).and_return(rule)
    end

    it 'applies the rule' do
      expect(TransactionRules::ApplyRule).to receive(:new).with(rule, anything).and_return(applier)
      expect(subject.rule_applier).to receive(:preview)

      subject.call
    end
  end
end
