class Widgets::CategoriesBreakdownComponent < ViewComponent::Base
  include Widgets::WidgetHelper

  def initialize(user, date)
    @user = user
    @date = date
  end

  def top_categories
    @top_categories ||= transactions_repo
      .top_categories(start_date..end_date)
      .where(is_credit: false)
      .limit(10)
      .preload(:category)
      .map { |t| [t.category.name, t.cat_amount] }
      .to_h
  end

  def options
    {
      height: '625px',
      class: 'box',
      options: {
        legend: {
          bottom: '-3px'
        },
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }
    }
  end

  def render?
    puts top_categories.inspect
    top_categories.present?
  end
end
