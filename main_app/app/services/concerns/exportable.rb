module Exportable
  extend ActiveSupport::Concern


  def initialize(base_scope, channel_name: nil)

  end

  def call(base_scope, job_id, channel_name: nil)
    temp_csv = Tempfile.new(["export-#{job_id}", '.csv'])

    total_record = base_scope.count

    processed_records = 0

    CSV.open(temp_csv.path, 'wb') do |csv|
      csv << ['ID', 'Name', 'Email', 'Created At']

      base_scope.find_each do |record|
        processed_records += 1
        csv << row(record)
        broadcast({ status: "processing", processed_records: processed_records, total_record: total_record }) if channel_name
      end
    end

  end

end