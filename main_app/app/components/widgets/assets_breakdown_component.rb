class Widgets::AssetsBreakdownComponent < ViewComponent::Base
  def initialize(user)
    @user = user
  end

  def accounts_based_assets
    @accounts_based_assets ||= @user.accounts
      .where(account_type: Account::POSITIVE_ACCOUNTS)
      .group(:account_type).sum(:balance)
  end

  def static_assets
    @static_assets ||= @user.assets
      .where(asset_type: Asset::POSITIVE_ASSET_TYPES)
      .group(:asset_type).sum(:value)
  end

  def total
    accounts_based_assets.values.sum + static_assets.values.sum
  end

  def all_asset_types
    (accounts_based_assets.keys + static_assets.keys).uniq
  end

  def data
    all_asset_types.map do |k|
      value = accounts_based_assets[k] || 0 + static_assets[k] || 0
      { name: k.to_s.humanize, value: (value / total * 100).round(2) }
    end
  end
end
