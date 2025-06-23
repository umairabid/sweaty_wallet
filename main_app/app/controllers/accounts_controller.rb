class AccountsController < ApplicationController
  before_action :set_account, only: %i[update merge destroy]
  before_action :set_selects, only: %i[index update]

  def index
    @accounts = current_user.accounts.preload(:connector)
  end

  def update
    @account.update!(account_params)
    @account.reload
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "account-row-#{@account.id}",
          partial: 'accounts/account_row',
          locals: { account: @account, bank_options: @bank_options,
                    account_types: @account_types }
        )
      end
      format.html { render html: '' }
    end
  end

  def merge
    target_id = params.permit(:target_id)[:target_id]
    Accounts::Merge.call(@account, target_id)
    redirect_to connectors_path, notice: 'Account merged successfully'
  end

  def destroy
    @account.soft_delete
    redirect_to connectors_path, notice: 'Account deleted successfully'
  end

  private

  def set_account
    @account = current_user.accounts.find(params['id'])
  end

  def account_params
    params.require(:account).permit(:name, :nick_name)
  end

  def set_selects
    selects = current_user_repo.select_options
    @bank_options = selects[:banks]
    @account_types = selects[:account_types]
  end

  def render_account_row; end
end
