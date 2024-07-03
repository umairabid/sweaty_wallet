class ImportBankJob < ApplicationJob
  queue_as :default

  def perform(params, user)
    connector = Connector.find_or_create_by!(user: user, bank: params[:bank]) do |conn|
      conn.auth_type = 'transient'
      conn.status = 'connected'
    end
    GoodJob::Batch.enqueue(on_finish: ImportBankCallbackJob, user: user, bank: params[:bank]) do
      params[:accounts].each do |account_params|
        ImportBankAccountJob.perform_later(connector, account_params)
      end
    end
  end


end
