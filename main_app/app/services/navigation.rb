class Navigation
  class << self
    include Rails.application.routes.url_helpers

    def loggedin_sidebar
      [
        { name: 'Dashboard', path: root_path, icon: 'dashboard' },
        { name: 'Net Worth', path: financial_assets_path, icon: 'net_worth' },
        { name: 'Manage Banks', path: connectors_path, icon: 'connectors' },
        { name: 'Categories', path: categories_path, icon: 'categories' },
        { name: 'Transactions', path: transactions_path, icon: 'transactions' },
        { name: 'Transaction Rules', path: transaction_rules_path, icon: 'transaction_rules' },
        { name: 'Account Settings', path: edit_user_registration_path, icon: 'account_settings' }
      ]
    end
  end
end
