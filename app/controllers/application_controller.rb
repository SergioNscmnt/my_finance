class ApplicationController < ActionController::Base
  helper_method :current_user
  before_action :authenticate_user!

  private

  def current_user
    return @current_user if defined?(@current_user)
    user_id = session[:user_id]
    @current_user = user_id && User.find_by(id: user_id)
  end

  def authenticate_user!
    redirect_to new_session_path, alert: "Faça login para continuar" unless current_user
  end
end
