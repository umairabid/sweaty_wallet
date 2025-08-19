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
    @params[:accounts].each do |account_params|
      Accounts::ImportAccountJob.perform_later(connector, account_params)
    end
  end

  def mark_inactive_accounts!
    existing_accounts = connector.accounts.pluck(:external_id)
    included_accounts = @params[:accounts].map { |account| account['external_id'] }
    excluded_accounts = existing_accounts - included_accounts
    connector.accounts.where(external_id: excluded_accounts).update_all(is_active: false)
  end

  def connector
    @connector ||= Connector.find_or_create_by!(user: @user, bank: @params[:bank]) do |conn|
      conn.auth_type = 'transient'
      conn.status = 'connected'
    end
  end
end
