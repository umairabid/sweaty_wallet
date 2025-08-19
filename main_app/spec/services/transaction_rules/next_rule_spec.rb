require 'rails_helper'

RSpec.describe TransactionRules::NextRule do
  let(:user) { create(:user) }
  let(:category_1) { create(:category, user: user, name: 'Category 1') }
  let!(:rule_1) { create(:transaction_rule, user: user, category: category_1, name: 'a') }
  let!(:rule_2) { create(:transaction_rule, user: user, category: category_1, name: 'b') }
  let!(:rule_3) { create(:transaction_rule, user: user, category: category_1, name: 'b') }
  let!(:rule_4) { create(:transaction_rule, user: user, category: category_1, name: 'c') }
  let!(:rule_5) { create(:transaction_rule, user: user, category: category_1, name: 'd') }

  context 'when rule has same name' do
    before do
      allow(TransactionRules::ApplyRule).to receive(:new) do |_rule|
        double(preview_count: 1)
      end
    end
    it 'returns next rule' do
      expect(TransactionRules::NextRule.call(rule_2)).to eq(rule_3)
    end
  end

  context 'when next rule does not have transactions' do
    before do
      allow(TransactionRules::ApplyRule).to receive(:new) do |rule|
        if rule.name == 'b'
          double(preview_count: 0)
        else
          double(preview_count: 1)
        end
      end
    end
    it 'returns next rule' do
      expect(TransactionRules::NextRule.call(rule_2)).to eq(rule_4)
    end
  end
end
