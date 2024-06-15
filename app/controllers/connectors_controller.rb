class ConnectorsController < ApplicationController
  before_action :set_connector, only: [:show, :create]
  before_action :set_bank_name, only: [:show]

  def show
    if @connector.persisted?
    else
      render :new
    end
  end

  def create
    puts 'hello world'
    respond_to do |format|
      format.turbo_stream
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
end
