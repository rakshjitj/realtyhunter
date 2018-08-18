require 'csv'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  skip_authorize_resource only: :logged_in_user
  before_action :logged_in_user
  #before_action :set_locale
  before_action ->{ @remote_ip = request.headers['REMOTE_ADDR'] }
  before_action :detect_device_variant
  # before_action :check_rack_mini_profiler # for profiling purposes only
  after_action  :clear_xhr_flash
  before_filter :redirect_https

    

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  # this throws an error when it comes to image deletion, as we do not navigate
  # to those records directly
  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:warning] = 'Sorry, that item was not found in our system.' #exception.message
    redirect_to action: 'index'
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

  def check_rack_mini_profiler
    # for example - if current_user.admin?
    if params[:rmp]
      Rack::MiniProfiler.authorize_request
    end
  end


  protected

    def stale_record_recovery_action
      flash.now[:danger] = "Another user has made a change to that record "+
        "since you accessed the edit form. Try again."
      render :edit, status: :conflict
    end

  private

    def redirect_https        
      redirect_to :protocol => "https://" unless request.ssl?
      return true
    end 
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

    # for our purposes, we treat tablets the same as desktop
    def detect_device_variant
      case request.user_agent
      when /iPad/i
        request.variant = :desktop #tablet
      when /iPhone/i
        request.variant = :phone
      when /Android/i && /mobile/i
        request.variant = :phone
      when /Android/i
        request.variant = :desktop #tablet
      when /Windows Phone/i
        request.variant = :phone
      else
        request.variant = :desktop
    end
    end
end
