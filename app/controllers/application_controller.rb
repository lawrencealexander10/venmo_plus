class ApplicationController < ActionController::Base
	before_filter :configure_permitted_parameters, if: :devise_controller?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.	
  protect_from_forgery with: :exception
  private
  def configure_permitted_parameters
 	devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:fname, :lname, :email, :profile_pic, :password, :password_confirmation) }
end
	def auth_user
		redirect_to "/static/index" unless user_signed_in?
	end

 
end