class Widgets::MonthAndYearStatsComponent < ViewComponent::Base
  include Widgets::WidgetHelper

  def month_spend
    transactions_repo.primary_by_range(start_date..end_date).where(is_credit: false).sum(:amount)
  end

  def month_income
    transactions_repo.primary_by_range(start_date..end_date).where(is_credit: true).sum(:amount)
  end

  def year_spend
    transactions_repo.primary_by_range(year_range).where(is_credit: false).sum(:amount)
  end

  def year_income
    transactions_repo.primary_by_range(year_range).where(is_credit: true).sum(:amount)
  end

  private

  def year_range
    @date.beginning_of_year..@date.end_of_year
  end
end
