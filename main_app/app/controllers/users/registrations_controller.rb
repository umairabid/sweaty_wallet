class Users::RegistrationsController < Devise::RegistrationsController
  layout "settings", only: [:edit]

  protected

  def after_update_path_for(resource)
    edit_user_registration_path(resource)
  end
end
