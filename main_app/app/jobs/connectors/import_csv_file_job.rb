class Connectors::ImportCsvFileJob < ApplicationJob
  queue_as :default

  include Broadcastable

  def perform(file_import)
    @channel_name = "file_import_#{file_import.id}"
    broadcast({ status: "importing_transactions" })
    file_import.update!(status: "processing")
    csv = CSV.parse(file_import.file.download, headers: true)
    bank = file_import.input["bank"]
    connector = Connector.find_or_create_by!(user: file_import.user, bank: bank) do |conn|
      conn.auth_type = "transient"
      conn.status = "connected"
    end
    accounts = csv.pluck("external_account_id").uniq
    account_transactions = csv.group_by { |row| row["external_account_id"] }
    accounts.each do |account_id|
      transactions = account_transactions[account_id]
      account = connector.accounts.find_or_create_by!(external_id: account_id) do |acc|
        transaction = transactions.first
        acc.name = transaction["account_name"]
        acc.account_type = transaction["account_type"]
        acc.currency = transaction["currency"]
      end
      Imports::ImportTransactions.call(account, account_transactions[account_id].map { |t| t.to_h.symbolize_keys })
    end
    file_import.update!(status: "success")
    broadcast({ status: "imported_transactions" })
  end

  def channel_name
    @channel_name
  end
end
