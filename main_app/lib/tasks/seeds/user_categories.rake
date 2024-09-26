# invoke like <rake seeds:user_categories[3]> where 3 is user id
namespace :seeds do
  desc "Seed user categories"
  task :user_categories, [:user_id] => :environment do |t, args|
    categories = {
      "Income" => [
        "Salary", "Business Income", "Investments", "Other Income",
      ],
      "Expenses" => [
        "Housing", "Utilities", "Groceries", "Shopping", "Personal Care", "Healthcare",
        "Insurance", "Entertainment", "Education", "Gifts", "Miscellaneous",
      ],
      "Transfers" => [
        "Between Accounts", "Peer-to-Peer Transfers", "Credit Card Payments", "Investments",
      ],
      "Financial Obligations" => [
        "Loan Payments", "Credit Card Debt", "Car Payment", "Other Debt Payment",
      ],
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
