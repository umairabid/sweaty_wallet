class Accounts::ImportAccountsCallbackJob < ApplicationJob
  queue_as :default

  def perform(connector, params)
    puts connector.inspect
    puts params.inspect
  end
end
