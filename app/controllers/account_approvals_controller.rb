class AccountApprovalsController < ApplicationController
  skip_before_action :logged_in_user

  def edit
    user = User.find_by(email: params[:email])
    #approvedd = user.authenticated?(:approval,  params[:id])
    puts "\n^^^^^ #{params[:company]}  #{params.inspect}"
    if user && !user.approved? && user.authenticated?(:approval,  params[:id])
      user.approve
      # TODO: VERIFY! notify user by email they've been approved
      UserMailer.account_approval_done(user).deliver_now
      company = Company.find_by(name: params[:company])
      #puts "***** #{@company} #{@company.admins}"
      user.company = company
      user.save
      flash[:success] = "Account Approved!"
      redirect_to user #TODO: send to admin dash?
    else
      flash[:danger] = "Invalid approval link"
      redirect_to root_url
    end
  end
end