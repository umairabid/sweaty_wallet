class CategoriesController < ApplicationController
  def index
    @parent_categories = current_user_repo.fetch_referencables[:parent_categories]
    @categories = current_user_repo.fetch_categories.order(updated_at: :desc)
  end

  def create
    raise "Category name cannot be blank" if category_params[:name].blank?
    raise "Parent category cannot be blank" if category_params[:parent_category_id].blank?

    current_user.categories.create!(category_params)
    redirect_to categories_path
  end

  def update
    @category = current_user.categories.find(params[:id])
    @category.update!(category_params)
    redirect_to categories_path
  end

  def new
    @parent_categories = current_user_repo.fetch_referencables[:parent_categories]
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "new_category_form",
          template: "categories/new",
          locals: { parent_categories: @parent_categories, model: Category.new },
        )
      end
      format.html { render html: "" }
    end
  end

  private

  def category_params
    params.require(:category).permit(:name, :parent_category_id)
  end
end
