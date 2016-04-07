class AccountActivationsController < ApplicationController
  skip_authorize_resource
  skip_before_action :logged_in_user

  def edit
    user = User.where(email: params[:email]).first
    # TODO: what if they are activated but not approved?
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      #log_in user # TODO: fix signup tests if you change this
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
