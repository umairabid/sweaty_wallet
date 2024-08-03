class AccountsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[import]
  before_action :set_account, only: %i[update]

  def import
    parameters = params.slice(:accounts, :bank).to_unsafe_hash
    job = ImportBankJob.perform_later(parameters, current_user)
    render json: { job_id: job.job_id }
  end

  def index
    @bank_options = bank_options
    @account_types = account_types
    @accounts = current_user.accounts.preload(:connector)
  end

  def update
    @account.update!(account_params)
    @account.reload
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "account-row-#{@account.id}",
          partial: "accounts/account_row",
          locals: { account: @account, bank_options: bank_options, account_types: account_types },
        )
      end

      format.html { render :new_extension }
    end
  end

  private

  def set_account
    @account = current_user.accounts.find(params["id"])
  end

  def account_params
    params.require(:account).permit(:name, :nick_name)
  end
end
