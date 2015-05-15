class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation"
  end

  # Company admin needs to approve this user
  def account_approval_needed(user, company)
    @user = user
    @company = company
    @emails = @company.admins.map(&:email)
    puts "--- #{@user} #{@company} #{@company.admins.inspect}"
    mail to: @emails, subject: "Account approval needed"
  end

  # company admin has just finished approving this user,
  # so notify the user
  def account_approval_done(user)
    @user = user
    mail to: @user.email, subject: "Account approved"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end

  def account_created_by_admin(user)
    @user = user
    mail to: user.email, subject: "Your account has been created"
  end
end
