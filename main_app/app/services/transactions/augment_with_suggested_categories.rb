class Transactions::AugmentWithSuggestedCategories
  include Callable

  def initialize(user, transactions)
    @transactions = transactions
    @user = user
  end

  def call
 
  end
end
