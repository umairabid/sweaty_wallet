class Widgets::AssetsLiabilitiesComponent < ViewComponent::Base
  def initialize(user)
    @user = user
  end

  def total
    net_worth_breakdown.total_assets + net_worth_breakdown.total_liabilities
  end

  def assets_percentage
    (net_worth_breakdown.total_assets * 100 / total).round(2)
  end

  def liabilities_percentage
    (net_worth_breakdown.total_liabilities * 100 / total).round(2)
  end

  def data
    [
      { name: 'Assets', value: assets_percentage },
      { name: 'Liabilities', value: liabilities_percentage }
    ]
  end

  def render?
    @user
  end

  private

  def net_worth_breakdown
    @user.net_worth_breakdown
  end
end
