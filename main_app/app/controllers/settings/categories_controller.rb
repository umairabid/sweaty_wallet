class Settings::CategoriesController < ApplicationController
  layout 'settings'

  def index
    @categories = current_user_repo.fetch_categories
  end

  def new
    @parent_categories = current_user_repo.fetch_referencables[:parent_categories]
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "new_category_form",
          template: "settings/categories/new",
          locals: { parent_categories: @parent_categories, model: Category.new }
        )
      end
      format.html { render html: "" }
    end
  end
end