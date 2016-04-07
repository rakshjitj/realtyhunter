class AccountApprovalsController < ApplicationController
  skip_authorize_resource
  skip_before_action :logged_in_user

  def edit
    @user = User.where(email: params[:email]).first
    if @user && !@user.approved? && @user.authenticated?(:approval,  params[:id])
      @user.approve
      UserMailer.account_approval_done(@user).deliver_now
      @company = Company.where(name: params[:company]).first
      flash[:success] = "#{@user.name} Approved!"
      redirect_to user #TODO: send to admin dash?
    else
      flash[:danger] = "Invalid approval link"
      redirect_to root_url
    end
  end
end
