require 'rails_helper'

RSpec.describe TransactionRules::PersistCondition do
  let(:user) { create(:user) }
  let(:target_category) { create(:category, user: user) }
  let(:condition_category) { create(:category, user: user) }

  describe '#call' do
    let(:params) { { type: 'category_id', category_id: condition_category.id } }
    let(:transaction_rule) do
      create(:transaction_rule, user: user, category: target_category,
        conditions: { type: 'group', conditions: [] })
    end

    context 'when no conditions are added' do
      it 'adds condition within the group' do
        described_class.call(transaction_rule, params)
        transaction_rule.reload
        group_condition = transaction_rule.conditions
        expect(group_condition['conditions'].size).to eq(1)
      end
    end

    context 'when group condition is already added' do
      let(:group_id) { SecureRandom.uuid }

      let(:transaction_rule) do
        create(
          :transaction_rule,
          user: user,
          category: target_category,
          conditions: {
            id: group_id,
            type: 'group',
            conditions: [
              {
                type: 'category_id',
                category_id: condition_category.id
              }
            ]
          }
        )
      end

      context 'when join_by is not present' do
        let(:params) { { group_id: group_id, type: 'tags', tags: 'gumroad, transfer' } }
        it 'raises error' do
          expect { described_class.call(transaction_rule, params) }.to raise_error(CustomerError)
        end
      end

      context 'when group id is missing or incorrect' do
        let(:params) { { group_id: SecureRandom.uuid, type: 'tags', tags: 'gumroad, transfer' } }
        it 'raises error' do
          expect { described_class.call(transaction_rule, params) }.to raise_error(CustomerError)
        end
      end

      context 'when params are correct' do
        let(:params) do
          { group_id: group_id, type: 'tags', tags: 'gumroad, transfer', join_by: 'or' }
        end

        it 'adds condition within the group' do
          described_class.call(transaction_rule, params)
          transaction_rule.reload
          group_condition = transaction_rule.conditions
          expect(group_condition['conditions'].size).to eq(2)
        end
      end

      context 'when adding group condition to an existing group' do
        let(:params) { { group_id: group_id, type: 'group', join_by: 'or' } }

        it 'adds the nested group condition' do
          described_class.call(transaction_rule, params)
          transaction_rule.reload
          group_condition = transaction_rule.conditions
          expect(group_condition['conditions'].size).to eq(2)
          expect(group_condition['conditions'].last['type']).to eq('group')
        end

        context 'when adding condition in nested group' do
          let(:nested_group_id) { SecureRandom.uuid }
          let(:params) { { group_id: nested_group_id, type: 'tags', tags: 'walmart' } }
          let(:transaction_rule) do
            create(
              :transaction_rule,
              user: user,
              category: target_category,
              conditions: {
                id: group_id,
                type: 'group',
                conditions: [
                  {
                    id: nested_group_id,
                    type: 'group',
                    conditions: []
                  }
                ]
              }
            )
          end

          it 'adds the nested group condition' do
            described_class.call(transaction_rule, params)
            transaction_rule.reload
            group_condition = transaction_rule.conditions
            expect(group_condition['conditions'].last['type']).to eq('group')
            expect(group_condition['conditions'].last['conditions'].size).to eq(1)
          end
        end
      end
    end
  end
end
