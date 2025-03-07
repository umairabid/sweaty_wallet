class Widgets::TopCategoriesComponent < ViewComponent::Base
  def initialize(user, date)
    @user = user
    @date = date
  end

  def top_categories
    transactions_repo.top_categories(start_date, end_date).limit(10)
  end

  private

  def start_date
    @date.beginning_of_month
  end

  def end_date
    @date.end_of_month
  end

  def transactions_repo
    @transactions_repo ||= TransactionsRepository.new(@user.transactions)
  end
end
