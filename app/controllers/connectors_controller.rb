class ConnectorsController < ApplicationController
  before_action :set_connector, only: [:show, :create]
  before_action :set_bank_name, only: [:show, :create]

  def show
    if @connector.persisted?
    else
      render :new
    end
  end

  def create
    @connector.assign_attributes connector_params
    #@connector.save!

    respond_to do |format|
      format.turbo_stream do
        if @connector.valid?
          render turbo_stream: turbo_stream.replace(:connector_process, partial: 'connectors/connector_process')
        else
          render turbo_stream: turbo_stream.replace(:new_connector_form, partial: 'connectors/connector_form')
        end
      end
    end
  end

  private

  def set_bank_name
    @bank_name = Connector::BANK_NAMES[params['id']]
  end

  def set_connector
    raise NotFound unless valid_bank?
    @connector = Connector.find_by(bank: params['id'], user: current_user) || Connector.new(user: current_user, bank: params['id'])
  end

  def valid_bank?
    Connector.banks.values.include? params['id']
  end

  def connector_params
    params.require(:connector).permit(:username, :password, :auth_type)
  end
end
