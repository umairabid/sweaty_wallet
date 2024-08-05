require "rails_helper"

RSpec.describe AccountsController, type: :controller do
  let(:user) { create(:user) }
  let(:connector) { create(:connector, user: user) }
  let(:account) { create(:account, connector: connector) }

  describe "routes" do
    before do
      sign_in user
    end

    context "put #update" do
      context "when name is being change" do
        it "updates name" do
          put :update, params: { id: account.id, account: { name: "Updated name" } }
          account.reload
          expect(account.name).to eq("Updated name")
        end
      end
    end

    context "post #import" do
      it "schedules import job" do
        expect(ImportBankJob).to receive(:perform_later).and_return(double(job_id: "123"))
        post :import
      end
    end
  end
end
