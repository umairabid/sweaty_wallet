class Accounts::ImportAccountsJob < ApplicationJob
  queue_as :default

  def perform(params, user)
    connector = Connector.find_or_create_by!(user: user, bank: params[:bank]) do |conn|
      conn.auth_type = "transient"
      conn.status = "connected"
    end
    GoodJob::Batch.enqueue(on_finish: Accounts::ImportAccountsCallbackJob, user: user, bank: params[:bank]) do
      params[:accounts].each do |account_params|
        Accounts::ImportAccountJob.perform_later(connector, account_params)
      end
    end
  end
end
