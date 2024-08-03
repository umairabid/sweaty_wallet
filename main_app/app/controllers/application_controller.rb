class ApplicationController < ActionController::Base
  layout :layout
  before_action :authenticate_user!

  private

  def layout
    devise_controller? ? "slim" : "application"
  end

  def authenticate_user!
    return if devise_controller?

    if user_signed_in?
      super
    else
      redirect_to login_path, notice: "if you want to add a notice"
      ## if you want render 404 page
      ## render :file => File.join(Rails.root, 'public/404'), :formats => [:html], :status => 404, :layout => false
    end
  end

  def bank_options
    return [] if current_user.blank?
    current_user.connectors.map { |c| [Connector::BANK_NAMES[c.bank], c.id] }
  end

  def account_types
    Account::ACCOUNT_TYPE_LABELS.map { |k, v| [v, k] }
  end

  def categories
    return [] if current_user.blank?
    current_user.categories.map { |c| [c.name, c.id] }
  end
end
