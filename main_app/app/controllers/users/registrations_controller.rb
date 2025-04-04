class Users::RegistrationsController < Devise::RegistrationsController
  layout "slim", except: [:edit]
  before_action :configure_permitted_parameters

  protected

  def after_update_path_for(resource)
    edit_user_registration_path(resource)
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  def after_sign_up_path_for(resource)
    new_user_session_path
  end

  # Permit additional fields during sign up and account update
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :avatar])
  end
end
