class ImportBankAccountJob < ApplicationJob
  queue_as :default

  def perform(connector, params)
    Imports::ImportAccount.call(connector, params)
  end

end
