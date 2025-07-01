class Connectors::ImportBankCallbackJob < ApplicationJob
  queue_as :default

  def perform(batch)
    connector = batch.properties[:connector]
    connector.touch
  end
end
