class Transactions::ExportJob < ApplicationJob
  queue_as :default

  def perform(user, filters: {})
    sleep(5)
    broadcast ({ status: "success" })
    sleep(10)
    broadcast ({ status: "complete" })
  end

  def broadcast(message)
    ActionCable.server.broadcast(channel_name, message)
  end

  def channel_name
    "background_process_#{job_id}"
  end
end
