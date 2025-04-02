class Connectors::ImportBankJob < ApplicationJob
  queue_as :default

  def perform(params, user)
    Imports::ImportBank.call(params, user)
  end
end
