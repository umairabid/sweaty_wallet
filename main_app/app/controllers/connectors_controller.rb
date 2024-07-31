class ConnectorsController < ApplicationController
  before_action :set_connector
  before_action :set_bank_name

  def new_direct
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(:new_connector, template: "connectors/new_direct")
      end

      format.html { render :new_direct }
    end
  end

  def new_extension
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(:new_connector, template: "connectors/new_extension")
      end

      format.html { render :new_extension }
    end
  end

  def show; end

  def create_direct
    render_lambda = lambda {
      render turbo_stream: turbo_stream.replace(:new_connector, partial: "connectors/direct/connector_form")
    }

    if @connector.valid?
      ConnectBankJob.perform_later(connector_params)
      render_lambda = lambda {
        render turbo_stream: turbo_stream.replace(:connector_process, partial: "connectors/direct/connector_process")
      }
    end

    respond_to { |format| format.turbo_stream(&render_lambda) }
  end

  private

  def bank
    params[:bank]
  end

  def set_bank_name
    @bank_name = Connector::BANK_NAMES[bank]
  end

  def set_connector
    raise NotFound unless valid_bank?

    @connector = Connector.find_by(bank: bank, user: current_user) ||
                 Connector.new(user: current_user, bank: bank)
  end

  def valid_bank?
    Connector.banks.keys.include? bank
  end

  def connector_params
    params.require(:connector)
          .permit(:username, :password, :auth_type)
          .to_h
          .merge!({ bank: bank, user_id: @connector.user_id })
  end
end
