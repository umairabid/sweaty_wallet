require "rails_helper"

RSpec.describe ConnectorsController, type: :controller do
  let(:user) { create(:user) }
  let(:connector) { create(:connector, user: user) }

  describe "routes" do
    before do
      sign_in user
    end

    context "post #import" do
      it "schedules import job" do
        expect(Connectors::ImportBankJob).to receive(:perform_later).and_return(double(job_id: "123"))
        post :import, params: { bank: connector.bank }
      end
    end
  end
end
