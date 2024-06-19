class ConnectBankJob < ApplicationJob
  queue_as :default

  def perform(connector)
    puts connector.inspect
    Connectors::Rbc.new(connector)
  end
end
