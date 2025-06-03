class Users::NetWorthBreakdown
  def initialize(user)
    @user = user
  end

  def net_worth
    total_assets - total_liabilities
  end

  def total_assets
    positive_accounts.sum(&:balance) + positive_assets.sum(&:value)
  end

  def total_liabilities
    negative_accounts.sum(&:balance) + negative_assets.sum(&:value)
  end

  private

  def positive_accounts
    @user.accounts.select { |a| Account::POSITIVE_ACCOUNTS.include?(a.account_type.to_sym) }
  end

  def negative_accounts
    @user.accounts.select { |a| Account::NEGATIVE_ACCOUNTS.include?(a.account_type.to_sym) }
  end

  def positive_assets
    @user.assets.select { |a| Asset::POSITIVE_ASSET_TYPES.include?(a.asset_type.to_sym) }
  end

  def negative_assets
    @user.assets.select { |a| Asset::NEGATIVE_ASSET_TYPES.include?(a.asset_type.to_sym) }
  end
end
