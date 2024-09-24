require "rails_helper"

RSpec.describe TransactionRules::DeleteCondition do
  let(:root_group_id) { SecureRandom.uuid }
  let(:nested_group_id) { SecureRandom.uuid }
  let(:user) { create(:user) }
  let(:category) { create(:category, user: user) }
  let(:conditions) {
    {
      id: root_group_id,
      type: "group",
      conditions: [
        {
          type: "type",
          value: "transfer",
        },
        {
          type: "category",
          value: "2",
        },
        {
          id: nested_group_id,
          type: "group",
          conditions: [
            {
              type: "type",
              value: "transfer",
            },
          ],
        },
      ],
    }
  }
  let(:transaction_rule) { create(:transaction_rule, user: user, conditions: conditions, category: category) }

  context "when removing condition from root group" do
    it "deletes condition within the group" do
      described_class.call(transaction_rule, group_id: conditions[:id], index: "0")
      transaction_rule.reload
      group_condition = transaction_rule.conditions
      expect(group_condition["conditions"].size).to eq(2)
      expect(group_condition["conditions"][0]["join_by"]).to be_falsey
      expect(group_condition["conditions"][0]["type"] == "category").to be_truthy
    end

    context "when all conditions are removed" do
      it "deletes the root group" do
        described_class.call(transaction_rule, group_id: conditions[:id], index: "0")
        described_class.call(transaction_rule, group_id: conditions[:id], index: "0")
        described_class.call(transaction_rule, group_id: conditions[:id], index: "0")

        transaction_rule.reload
        group_condition = transaction_rule.conditions
        expect(group_condition).to eq({})
      end
    end
  end

  context "when removing condition from nested group" do
    context "when nested group has one condition" do
      it "removes the group" do
        described_class.call(transaction_rule, group_id: nested_group_id, index: "0")
        transaction_rule.reload
        group_condition = transaction_rule.conditions
        expect(group_condition["conditions"].size).to eq(2)
        expect(group_condition["conditions"].any? { |c| c["type"] == "false" }).to be(false)
      end
    end
  end
end
