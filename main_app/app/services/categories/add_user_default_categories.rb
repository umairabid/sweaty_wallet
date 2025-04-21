class Categories::AddUserDefaultCategories
  include Callable

  CATEGORIES = {
    'Income' => [
      'Salary', 'Business Income', 'Investments', 'Other Income'
    ],
    'Expenses' => [
      'Accommodation', 'Utilities', 'Groceries', 'Shopping', 'Personal Care', 'Healthcare',
      'Insurance', 'Entertainment', 'Education', 'Gifts', 'Miscellaneous', 'Other Expenses',
      'Commute', 'Travel'
    ],
    'Transfers' => [
      'Between Accounts', 'Peer-to-Peer Transfers', 'Credit Card Payments', 'Investments'
    ],
    'Financial Obligations' => [
      'Loan Payments', 'Credit Card Debt', 'Car Payment', 'Other Debt Payment'
    ]
  }.freeze

  def initialize(user)
    @user = user
  end

  def call
    CATEGORIES.keys.each do |key|
      parent_cat = Category.find_or_create_by!(user: @user, name: key)
      CATEGORIES[key].each do |c|
        Category.find_or_create_by!(user: @user, name: c, parent_category_id: parent_cat.id)
      end
    end
  end
end
