class Transactions::SetSuggestedCategoriesJob < ApplicationJob
  queue_as :default

  def perform(user, transactions)
    Transactions::SetSuggestedCategories.call(user, transactions)
  end
end
