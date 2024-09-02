require "rails_helper"

RSpec.describe TransactionRules::ApplyRule do
  let(:user) { create(:user) }
  let(:connector) { create(:connector, user: user) }
  let(:account) { create(:account, connector: connector) }
  let(:category_1) { create(:category, user: user, name: "Category 1") }
  let(:category_2) { create(:category, user: user, name: "Category 2") }
  let(:category_3) { create(:category, user: user, name: "Category 3") }
  let(:category_4) { create(:category, user: user, name: "Category 4") }

  context "when conditions have groups" do
    let!(:transaction_1) { create(:transaction, account: account, category: category_1, is_credit: false) }
    let!(:transaction_2) { create(:transaction, account: account, category: category_4, is_credit: true, description: "jamal is my kamal") }
    let!(:transaction_3) { create(:transaction, account: account, category: category_4, is_credit: true, description: "jamal is my hamal") }
    let(:transaction_rule) do
      create(
        :transaction_rule,
        user: user,
        category: create(:category, user: user),
        conditions: {
          "id" => "fa279972-08bb-4049-86a0-c5720081925c",
          "type" => "group",
          "conditions" => [
            { "id" => "6b5b7f0e-911c-41ac-af06-a48fe62f9218",
             "type" => "group",
             "join_by" => nil,
             "conditions" => [
              { "type" => "category_id", "value" => category_1.id, "join_by" => nil },
              { "type" => "category_id", "value" => category_2.id, "join_by" => "or" },
              { "type" => "category_id", "value" => category_3.id, "join_by" => "or" },
            ] },
            { "id" => "6fe701d4-c85e-4467-a6cc-f432b7f0ed70",
             "type" => "group",
             "join_by" => "or",
             "conditions" => [
              { "type" => "tags", "value" => "jamal, kamal", "join_by" => nil },
              { "type" => "type", "value" => "credit", "join_by" => "and" },
            ] },
          ],
        },
      )
    end

    it "applies rule" do
      response = described_class.new(transaction_rule).preview
      expect(response.size).to eq(2)
      response_by_id = response.index_by(&:id)
      expect(response_by_id[transaction_1.id].category_id).to eq(category_1.id)
      expect(response_by_id[transaction_2.id].category_id).to eq(category_4.id)
    end
  end
end
