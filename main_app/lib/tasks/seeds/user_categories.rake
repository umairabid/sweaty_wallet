require "factory_bot_rails"

# invoke like <rake seeds:user_categories[3]> where 3 is used id
namespace :seeds do
  desc "Seed user categories"
  task :user_categories, [:user_id] => :environment do |t, args|
    categories = {
      "Income" => [
        "Salary", "Business Income", "Investements", "Other Income",
      ],
      "Personal Expenses" => [
        "Housing", "Utilities", "Food", "Shopping", "Personal Care", "Healthcare",
        "Insurance", "Entertainment", "Education", "Gifts", "Cash Withdrawals", "Fees and Charges",
      ],
      "Finance" => [
        "Loan Payments", "Credit Card Payments", "Car Payment", "Other Debt Payment",
      ],
      "Transfers" => [],
    }

    user = User.find args[:user_id]
    categories.keys.each do |key|
      parent_cat = Category.create!(user: user, name: key)
      categories[key].each do |c|
        Category.create!(user: user, name: c, parent_category_id: parent_cat.id)
      end
    end
  end
end
