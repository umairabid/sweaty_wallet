class Transactions::AugmentWithSuggestedCategories
  include callable

  def initialize(user, transactions)
    @transactions = transactions
    @user = user
  end

  def call; end
end
