class BankConnectorChannel < ApplicationCable::Channel
  def subscribed
    stream_from "bank_connector_#{params['bank_id']}_#{params['user_id']}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
