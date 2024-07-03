class AccountsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[import]

  def import
    parameters = params.slice(:accounts, :bank).to_unsafe_hash
    job = ImportBankJob.perform_later(parameters, current_user)
    render json: { job_id: job.job_id }
  end

  def index
    @accounts = current_user.accounts.preload(:connector)
  end
end