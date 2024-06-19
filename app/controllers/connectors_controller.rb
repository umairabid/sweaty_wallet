class ConnectorsController < ApplicationController
  before_action :set_connector
  before_action :set_bank_name

  def new
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(:new_connector, template: 'connectors/new')
      end

      format.html {  render :new }
    end
  end
  
  def show
    
  end

  def create
    @connector.assign_attributes connector_params
    #@connector.save!
    render_lambda = -> { render turbo_stream: turbo_stream.replace(:new_connector, partial: 'connectors/connector_form') }

    if @connector.valid?
      ConnectBankJob.perform_later(connector_params)
      render_lambda = -> { render turbo_stream: turbo_stream.replace(:connector_process, partial: 'connectors/connector_process') }
    end

    respond_to { |format| format.turbo_stream &render_lambda }
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
    params.require(:connector)
    .permit(:username, :password, :auth_type)
    .to_h
    .merge!({bank: params['id'], user_id: @connector.user_id})
  end
end
