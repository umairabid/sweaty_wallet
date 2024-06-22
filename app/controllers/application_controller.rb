# frozen_string_literal: true

class ApplicationController < ActionController::Base
  layout :layout
  before_action :authenticate_user!

  private

  def layout
    devise_controller? ? 'slim' : 'application'
  end

  def authenticate_user!
    return if devise_controller?

    if user_signed_in?
      super
    else
      redirect_to login_path, notice: 'if you want to add a notice'
      ## if you want render 404 page
      ## render :file => File.join(Rails.root, 'public/404'), :formats => [:html], :status => 404, :layout => false
    end
  end
end
