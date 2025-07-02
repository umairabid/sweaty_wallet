class ApplicationController < ActionController::Base
  include Pagy::Backend

  authorize_resource class: false
  helper_method :sidebar_menu

  layout :layout
  before_action :authenticate_user! # Devise authentication

  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      redirect_to root_path, alert: exception.message
    else
      redirect_to new_user_session_path, alert: exception.message
    end
  end

  def current_user_repo
    @current_user_repo ||= CurrentUserRepository.new(current_user)
  end

  def set_user_references
    @user_references = current_user_repo.select_options
  end

  def sidebar_menu
    Navigation.loggedin_sidebar
  end

  private

  def layout
    devise_controller? ? 'slim' : 'application'
  end
end
