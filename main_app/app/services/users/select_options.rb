class Users::SelectOptions
  include Callable

  def initialize(repo)
    @repo = repo
  end

  def call
    {
      banks: bank_options,
      categories: categories_options,
      account_types: account_type_options,
      accounts: account_options,
      transaction_types: [['Select Type', ''], %w[Credit credit], %w[Debit debit]],
      parent_categories: parent_categories_options,
      all_banks: [['Select Bank', '']] + all_banks
    }
  end

  private

  def all_banks
    banks = Connector::BANKS_CONFIG.keys
    banks = banks.select { |b| b != "example_bank" } if Rails.env.production?
    banks.map { |b| [Connector::BANKS_CONFIG[b][:name], b] }
  end

  def categories_options
    [['Select Category', '']] + [['Uncategorized', '-1']] + @repo.categories.map do |c|
      [c.name, c.id]
    end
  end

  def bank_options
    [['Select Bank', '']] + @repo.connectors.map { |c| [c.bank_name, c.id] }
  end

  def account_type_options
    [['Select Account Type', '']] + Account::FILTERABLE_ACCOUNT_TYPES.map do |v|
      [Account::ACCOUNT_TYPE_LABELS[v], v]
    end
  end

  def account_options
    options = @repo.accounts.select do |a|
      Account::FILTERABLE_ACCOUNT_TYPES.include?(a.account_type.to_sym)
    end
    [['Select Accounts', '']] + options.map { |a| [a.name, a.id] }
  end

  def parent_categories_options
    options = @repo.parent_categories.map { |c| [c.name, c.id] }
    [['Select Parent Category', '']] + options
  end
end
