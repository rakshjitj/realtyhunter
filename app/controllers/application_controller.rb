require 'csv'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  skip_authorize_resource :only => :logged_in_user
  before_action :logged_in_user
  #before_action :set_locale
  before_action ->{ @remote_ip = request.headers['REMOTE_ADDR'] }
  after_filter :clear_xhr_flash
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  
  protect_from_forgery with: :exception
  include SessionsHelper
  before_action :expire_hsts

  def clear_xhr_flash
    if request.xhr?
      # Also modify 'flash' to other attributes which you use in your common/flashes for js
      flash.discard
    end
  end
  private

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end


	  def expire_hsts
  	  response.headers["Strict-Transport-Security"] = 'max-age=0'
  	end

end
