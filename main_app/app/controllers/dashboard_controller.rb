class DashboardController < ApplicationController
  before_action :set_months, only: [:index]
  before_action :set_date, only: [:index]

  def index
  end

  private

  def set_months
    current_date = Time.zone.now.to_date.beginning_of_month
    @months = []

    6.downto(0) do |months_ago|
      month_date = current_date
      @months << [month_date.strftime("%B %Y"), month_date]
      current_date -= 1.month
    end
  end

  def set_date
    @date = params[:date].present? && Date.parse(params[:date]) || Time.zone.now.to_date.beginning_of_month
  end
end
