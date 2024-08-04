require "rails_helper"

RSpec.describe AccountsController, type: :controller do
  let(:user) { create(:user) }
  let(:connector) { create(:connector, user: user) }
  let(:account) { create(:account, connector: connector) }

  describe "PUT #update" do
    context "when name is being change" do
      before do
        sign_in user
      end

      it "updates name" do
        put :update, params: { id: account.id, account: { name: "Updated name" } }
        account.reload
        expect(account.name).to eq("Updated name")
      end
    end
  end
end
