class CurrentUserRepository
  def initialize(base_scope)
    @base_scope = base_scope
  end

  def fetch_categories
    @base_scope.categories.where.not(parent_category_id: nil).order(name: :asc).preload(:parent_category)
  end

  def fetch_parent_categories
    @base_scope.categories.where(parent_category_id: nil)
  end

  def fetch_transaction_rules
    @base_scope.transaction_rules.order(name: :asc)
  end

  # returns data references by various forms
  def fetch_referencables
    {
      banks: [["Select Bank", ""]] +
             @base_scope.connectors.map { |c| [c.bank_name, c.id] },
      categories: [["Select Category", ""]] + [["Uncategorized", "-1"]] +
                  fetch_categories.map { |c| [c.name, c.id] },
      account_types: [["Select Account Type", ""]] +
                     Account::FILTERABLE_ACCOUT_TYPES.map { |v| [Account::ACCOUNT_TYPE_LABELS[v], v] },
      accounts: [["Select Accounts", ""]] +
                @base_scope.accounts.select { |a| Account::FILTERABLE_ACCOUT_TYPES.include?(a.account_type.to_sym) }
                  .map { |a| [a.name, a.id] },
      transaction_types: [["Select Type", ""], ["Credit", "credit"], ["Debit", "debit"]],
      parent_categories: [["Select Parent Category", ""]] + fetch_parent_categories.map { |c| [c.name, c.id] },
    }
  end
end
