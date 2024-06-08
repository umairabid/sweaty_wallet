class ApplicationController < ActionController::Base
  layout :layout

  private

  def layout
    devise_controller? ? "slim" : "application"
  end
end
