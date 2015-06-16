class AddedByAdminsController < ApplicationController
  skip_authorize_resource
  skip_before_action :logged_in_user
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  
  def edit
  end

  def update
    if password_blank?
      flash.now[:danger] = "Password can't be blank"
      render 'edit'
    elsif @user.update(user_params)
      @user.activated
      log_in @user
      flash[:success] = "Password has been changed! You can now use your account."
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # Returns true if password is blank.
    def password_blank?
      params[:user][:password].blank?
    end

    # Before filters

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # Confirms a valid user.
    def valid_user
      unless (@user && @user.approved? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end    
end
