require "csv"

module Exportable
  include Broadcastable
  extend ActiveSupport::Concern

  def initialize(base_scope, channel_name = nil)
    @base_scope = base_scope
    @channel_name = channel_name
  end

  def call
    temp_csv = Tempfile.new(["export-file", ".csv"])
    total_record = @base_scope.count
    processed_records = 0

    CSV.open(temp_csv.path, "wb") do |csv|
      csv << columns.keys

      @base_scope.find_each do |record|
        processed_records += 1
        csv << row(record)
        broadcast({ status: "processing", html: "#{processed_records} out of #{total_record} are processed" }) if channel_name
      end
    end
    temp_csv
  end

  def row(record)
    columns.map { |key, value| record.public_send(value.to_sym) }
  end

  def channel_name
    @channel_name
  end
end
