class Widgets::AssetsLiabilitiesComponent < ViewComponent::Base
  def initialize(user)
    @user = user
  end

  def total
    net_worth_breakdown.total_assets + net_worth_breakdown.total_liabilities
  end

  def assets_percentage
    return 0 if total.zero?

    net_worth_breakdown.total_assets
  end

  def liabilities_percentage
    return 0 if total.zero?

    net_worth_breakdown.total_liabilities
  end

  def data
    [
      { name: 'Assets', value: assets_percentage },
      { name: 'Liabilities', value: liabilities_percentage }
    ]
  end

  def render?
    @user && total.positive?
  end

  def options
    {
      options: {
        toolbox: {
          show: true, magicType: { type: %w[line bar] }
        },
        legend: { show: true }
      },
    }
  end

  private

  def net_worth_breakdown
    @user.net_worth_breakdown
  end
end
