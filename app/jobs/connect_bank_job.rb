class ConnectBankJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts 'I am here'
  end
end
