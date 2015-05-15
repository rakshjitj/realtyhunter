class SessionsController < ApplicationController
  skip_before_action :logged_in_user, only: [:new, :create]
  
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated? && user.approved?
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or user
      else
        if !user.activated?
          message  = "Account not activated. "
          message += "Check your email for the activation link."
        elsif !user.approved
          message  = "Account not approved. "
          message += "Contact your company's admin if you don't receive an approval in the next 24hrs."
        end
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

end
