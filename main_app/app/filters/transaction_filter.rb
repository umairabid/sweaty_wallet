class TransactionFilter
  attr_reader :query,
              :categories,
              :time_range,
              :account_type,
              :bank,
              :type,
              :account_id,
              :selects

  FILTERABLE_ACCOUT_TYPES = [:credit_card, :deposit_account]

  def initialize(user, params = {})
    @user = user
    @query = params[:query] || ""
    @categories = params[:categories] || ""
    @time_range = params[:time_range] || ""
    @bank = params[:bank] || ""
    @account_type = params[:account_type] || ""
    @type = params[:type] || ""
    @account_id = params[:account_id] || ""
    set_select_options
  end

  def has?(name)
    self.send(name).present?
  end

  private

  def set_select_options
    @selects = {
      banks: [["Select Bank", ""]] + @user.connectors.map { |c| [Connector::BANK_NAMES[c.bank], c.id] },
      categories: [["Select Category", ""]] + @user.categories.where.not(parent_category_id: nil).map { |c| [c.name, c.id] },
      account_types: [["Select Account Type", ""]] + FILTERABLE_ACCOUT_TYPES.map { |v| [Account::ACCOUNT_TYPE_LABELS[v], v] },
      accounts: [["Select Accounts", ""]] + @user.accounts.select { |a| FILTERABLE_ACCOUT_TYPES.include?(a.account_type.to_sym) }.map { |a| [a.name, a.id] },
      time_ranges: [["Select Duration", ""], ["Last Month", 1], ["Last Two Months", 2], ["Last Three Months", 3]],
      types: [["Select Type", ""], ["Credit", "credit"], ["Debit", "debit"]],
    }
  end
end
