class Transactions::ExportJob < ApplicationJob
  include Broadcastable
  include Rails.application.routes.url_helpers
  queue_as :default

  def perform(user, filters: {})
    repo = TransactionsRepository.new(user.transactions)
    filter = TransactionFilter.new(user, filters || {})
    scope = repo.fetch_by_filters(filter)
    file = Transactions::Export.call(scope, channel_name)
    if file.nil?
      broadcast({ status: "success", html: 'No records were found to export' })
      return
    end

    user.transaction_exports.attach({
      io: File.open(file.path),
      content_type: "text/csv",
      filename: File.basename(file.path),
      identify: true
    })

    user.save!
    url = rails_blob_path(user.transaction_exports.last, only_path: true)
    broadcast({ status: "success", html: ApplicationController.render(
      partial: "helpers/background_success_messages/export_transactions",
      locals: { url: url}, # Pass any locals the partial requires
    ) })
  end

  def channel_name
    "background_process_#{job_id}"
  end
end
