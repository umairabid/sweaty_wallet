class FileImportChannel < ApplicationCable::Channel
  def subscribed
    stream_from "file_import_#{params["file_import_id"]}"
  end
end
