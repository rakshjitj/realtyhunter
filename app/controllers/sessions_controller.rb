class SessionsController < ApplicationController
  skip_authorize_resource
  skip_before_action :logged_in_user, only: [:new, :create]
  
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    #puts "\n^^^^ found user #{user.inspect}"
    if user && user.authenticate(params[:session][:password])
      #puts "111111"
      if user.activated? && user.approved?
        #puts "222222"
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        user_home
      else
        #puts "444444"
        if !user.activated?
          #puts "55555"
          message  = "Account not activated. "
          message += "Check your email for the activation link."
        elsif !user.approved
          #puts "66666"
          message  = "Account not approved. "
          message += "Contact your company's admin if you don't receive an approval in the next 24hrs."
        else
          #puts "77777"
          message = "Something went wrong"
        end
        flash[:warning] = message
        redirect_to root_url
      end
    else
      #puts "3333333"
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  def user_home
    redirect_to root_path unless current_user
    
    if current_user.is_external_vendor?
      redirect_to current_user
    elsif current_user.handles_residential?
      redirect_to residential_listings_path
    elsif current_user.handles_commercial?
      redirect_to commercial_listings_path
    else
      redirect_to current_user
    end
  end

end
