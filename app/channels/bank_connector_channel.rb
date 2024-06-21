class BankConnectorChannel < ApplicationCable::Channel
  def subscribed
    stream_from "bank_connector_#{params['bank_id']}_#{params['user_id']}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    connector = Connector.find_by(user_id: params['user_id'], bank: params['bank_id'])
    connector.two_factor_key = data['two_factor_key']
    connector.save!
  end
end
