class Widgets::LiabilitiesBreakdownComponent < ViewComponent::Base
  def initialize(user)
    @user = user
  end

  def accounts_based_liabilities
    @accounts_based_liabilities ||= @user.accounts
      .where(account_type: Account::NEGATIVE_ACCOUNTS)
      .group(:account_type).sum(:balance)
  end

  def static_liabilities
    @static_liabilities ||= @user.assets
      .where(asset_type: Asset::NEGATIVE_ASSET_TYPES)
      .group(:asset_type).sum(:value)
  end

  def total
    accounts_based_liabilities.values.sum + static_liabilities.values.sum
  end

  def all_liability_types
    (accounts_based_liabilities.keys + static_liabilities.keys).uniq
  end

  def data
    all_liability_types.map do |k|
      value = accounts_based_liabilities[k] || 0 + static_liabilities[k] || 0
      { name: k.to_s.humanize, value: }
    end
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

end
