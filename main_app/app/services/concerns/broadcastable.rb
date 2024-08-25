module Broadcastable

  extend ActiveSupport::Concern

  def broadcast(message)
    ActionCable.server.broadcast(channel_name, message) if channel_name
  end

  def channel_name
    nil
  end
end
