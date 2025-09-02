class Widgets::TopCategoriesComponent < ViewComponent::Base
  include Widgets::WidgetHelper

  def top_categories
    transactions_repo.top_categories(start_date..end_date).limit(10)
  end

  def render?
    top_categories.present?
  end
end
