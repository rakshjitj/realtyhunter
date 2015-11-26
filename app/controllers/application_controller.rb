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
    redirect_to root_url, alert: exception.message
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:warning] = 'Sorry, that item was not found in our system.' #exception.message
    redirect_to :action => 'index'
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

  rescue_from ActiveRecord::StaleObjectError do |exception|
    respond_to do |format|
      format.html {
        correct_stale_record_version
        stale_record_recovery_action
      }
      format.xml  { head :conflict }
      format.json { head :conflict }
    end
  end

  protected

    def stale_record_recovery_action
      flash.now[:danger] = "Another user has made a change to that record "+
        "since you accessed the edit form. Try again."
      render :edit, :status => :conflict
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
