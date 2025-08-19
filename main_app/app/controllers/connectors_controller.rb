class ConnectorsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[import]
  before_action :set_user_references, only: %i[new index create]

  def import
    parameters = params.slice(:accounts, :bank).to_unsafe_hash
    job = Connectors::ImportBankJob.perform_later(parameters, current_user)
    render json: { job_id: job.job_id }
  end

  def import_csv
    file_import = current_user.file_imports.create!(file: params[:csv],
      input: { bank: params[:bank] })
    Connectors::ImportCsvFileJob.perform_later(file_import)
    render json: { file_import_id: file_import.id }
  end

  def index
    @connectors = current_user.connectors.preload(:accounts).select { |c| c.accounts.any? }
  end

  def new
    @bank = bank
    @mode = params[:mode]
    @connector = current_user.connectors.find_or_initialize_by(bank: @bank)
    locals = { bank: @bank, mode: @mode, connector: @connector, start_direct_process: false }
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(:new_connector, template: 'connectors/new',
          locals:)
      end

      format.html { render :new, locals: }
    end
  end

  def create
    @connector = current_user.connectors.find_or_initialize_by(bank:)
    @connector.assign_attributes(connector_params)
    @connector.save
    ConnectBankJob.perform_later(@connector) if @connector.valid?

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(:new_connector, template: 'connectors/new', locals: {
          connector: @connector,
          bank:,
          mode: params[:mode],
          start_direct_process: @connector.save
        })
      end
    end
  end

  def new_direct
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(:new_connector,
          template: 'connectors/new_direct')
      end

      format.html { render :new_direct }
    end
  end

  def create_direct
    render_lambda = lambda {
      render turbo_stream: turbo_stream.replace(:new_connector,
        partial: 'connectors/direct/connector_form')
    }

    if @connector.valid?
      ConnectBankJob.perform_later(connector_params)
      render_lambda = lambda {
        render turbo_stream: turbo_stream.replace(:connector_process,
          partial: 'connectors/direct/connector_process')
      }
    end

    respond_to { |format| format.turbo_stream(&render_lambda) }
  end

  private

  def bank
    params[:bank]
  end

  def connector_params
    params.require(:connector).permit(:auth_type, :username, :password, :two_factor_key,
      :auth_method)
  end
end
