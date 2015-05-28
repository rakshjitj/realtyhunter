require 'csv'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #check_authorization
  skip_authorize_resource :only => :logged_in_user
  before_action :logged_in_user

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  
  protect_from_forgery with: :exception
  include SessionsHelper
  before_filter :expire_hsts
  
  private

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        #puts "LOGIN_URL: ******* #{login_url.inspect}"
        redirect_to login_url
      end
    end


	  def expire_hsts
  	  response.headers["Strict-Transport-Security"] = 'max-age=0'
  	end
end
