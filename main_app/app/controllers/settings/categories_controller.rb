class Settings::CategoriesController < ApplicationController
  layout 'settings'

  def index
    @categories = current_user_repo.fetch_categories
  end
end