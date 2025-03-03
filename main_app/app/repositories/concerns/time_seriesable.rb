module Concerns::TimeSeriesable
  extend ActiveSupport::Concern

  def accumulate_time_series(series, start_date, end_date)
    (start_date..end_date).each_with_object({}) do |date, hash|
      hash[date] = (series[date] || 0) + (hash[date - 1] || 0)
    end
  end
end
