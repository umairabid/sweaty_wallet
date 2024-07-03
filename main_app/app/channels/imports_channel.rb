class ImportsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "import_#{params['job_id']}"
  end
end
