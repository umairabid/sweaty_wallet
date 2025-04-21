class Accounts::Merge
  include Callable

  def initialize(account, target_id)
    @account = account
    @target_id = target_id
    set_target
  end

  def call
    source_account_transactions = @account.transactions
    target_account_transactions = @target.transactions
    @target.transactions = target_account_transactions + source_account_transactions
    @target.save!
    @account.reload
    @account.destroy!
  end

  private

  def set_target
    other_accounts = @account.other_accounts.map(&:id)
    raise ArgumentError, 'Target account not found' unless other_accounts.include?(@target_id.to_i)

    @target = @account.other_accounts.find(@target_id)
  end
end
