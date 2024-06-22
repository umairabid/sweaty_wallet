# frozen_string_literal: true

class ConnectBankJob < ApplicationJob
  queue_as :default

  def perform(connector)
    Connectors::Rbc.call(connector)
  end
end
