class Imports::ImportBank
  include Callable

  def initialize(params, user)
    @params = params
    @user = user
  end

  def call
    mark_inactive_accounts!
    import!
  end

  private

  def import!
    GoodJob::Batch.enqueue(on_finish: Connectors::ImportBankCallbackJob, connector:) do
      @params[:accounts].each do |account_params|
        Accounts::ImportAccountJob.perform_later(connector, account_params)
      end
    end
  end

  def mark_inactive_accounts!
    existing_accounts = connector.accounts.pluck(:external_id)
    puts existing_accounts.inspect
    included_accounts = @params[:accounts].map { |account| account["external_id"] }
    puts included_accounts.inspect
    puts @params[:accounts].map { |account| account[:external_id] }.inspect
    excluded_accounts = existing_accounts - included_accounts
    puts excluded_accounts.inspect
    connector.accounts.where.not(id: excluded_accounts).update_all(is_active: false)
  end

  def connector
    @connector ||= Connector.find_or_create_by!(user: @user, bank: @params[:bank]) do |conn|
      conn.auth_type = "transient"
      conn.status = "connected"
    end
  end
end
