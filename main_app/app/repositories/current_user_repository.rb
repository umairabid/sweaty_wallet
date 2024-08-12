class CurrentUserRepository
  def initialize(base_scope)
    @base_scope = base_scope
  end

  # returns data references by various forms
  def fetch_referencables
    {
      banks: [["Select Bank", ""]] +
             @base_scope.connectors.map { |c| [Connector::BANK_NAMES[c.bank], c.id] },
      categories: [["Select Category", ""]] +
                  @base_scope.categories.where.not(parent_category_id: nil).map { |c| [c.name, c.id] },
      account_types: [["Select Account Type", ""]] +
                     Account::FILTERABLE_ACCOUT_TYPES.map { |v| [Account::ACCOUNT_TYPE_LABELS[v], v] },
      accounts: [["Select Accounts", ""]] +
                @base_scope.accounts.select { |a| Account::FILTERABLE_ACCOUT_TYPES.include?(a.account_type.to_sym) }
                  .map { |a| [a.name, a.id] },
      transaction_types: [["Select Type", ""], ["Credit", "credit"], ["Debit", "debit"]],
    }
  end
end
