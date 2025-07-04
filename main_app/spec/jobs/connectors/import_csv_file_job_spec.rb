require "rails_helper"

RSpec.describe Connectors::ImportCsvFileJob, type: :job do
  let(:user) { create(:user) }
  let(:file) { Rails.root.join("spec", "support", "transactions.csv") }
  let(:file_import) { create(:file_import, user: user, file: file) }

  context "perform" do
    context "when connector and accounts does not exists" do
      it "creates the connector" do
        expect { described_class.perform_now(file_import) }.to change { Connector.count }.by(1).and change { Account.count }.by(2)
      end

      it "creates the transactions" do
        expect { described_class.perform_now(file_import) }.to change { Transaction.count }.by(4)
      end
    end

    context "when connector exists" do
      let!(:connector) { create(:connector, user: user) }

      it "uses the connector" do
        expect { described_class.perform_now(file_import) }.to change { Connector.count }.by(0).and change { Account.count }.by(2)
      end

      context "when accounts exists" do
        let!(:account) { create(:account, connector: connector, external_id: "credit_card_external_id") }

        it "uses the account" do
          expect { described_class.perform_now(file_import) }.to change { Connector.count }.by(0).and change { Account.count }.by(1)
        end
      end
    end
  end
end
