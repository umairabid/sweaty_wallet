class BackgroundProcessChannel < ApplicationCable::Channel
  def subscribed
    stream_from "background_process_#{params["job_id"]}"
  end
end
