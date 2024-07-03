class Imports::ImportAccount
  include Callable

  def initialize(connector, params)
    @connector = connector
    @params = params
  end

  def call
    persist!
    Imports::ImportTransactions.call(account, @params[:transactions])
  end

  def persist!
    if account
      account.update!(update_params)
    else
      @connector.accounts.create!(create_params)
    end
  end

  def account
    Account.find_by(external_id: @params[:external_id])
  end

  def create_params
    @create_params ||= {
      account_type: @params[:type],
      balance: @params[:balance].class == String ? @params[:balance].tr(",", "").to_d : @params[:balance],
      currency: @params[:currency],
      is_active: @params[:is_active],
      nick_name: @params[:nick_name],
      external_id: @params[:external_id],
      name: @params[:account_name],
    }
  end

  def update_params
    @update_params ||= begin
        params = create_params.dup
        params.delete(:nick_name)
        params
      end
  end
end
