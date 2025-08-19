class Transactions::SetSuggestedCategoriesJob < ApplicationJob
  include Broadcastable

  queue_as :default

  def perform(user, transactions)
    broadcast({ status: 'started' })
    sleep(50)
    Transactions::SetSuggestedCategories.call(user, transactions)
    broadcast({ status: 'finished' })
  rescue StandardError => e
    broadcast({ status: 'error', message: e.message })
  end

  def channel_name
    "background_process_#{job_id}"
  end
end
