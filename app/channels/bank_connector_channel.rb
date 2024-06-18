class BankConnectorChannel < ApplicationCable::Channel
  def subscribed
    stream_from "bank_connector"
    ActionCable.server.broadcast("bank_connector", { body: "This Room is Best Room." })
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
