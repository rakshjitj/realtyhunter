class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation",
        tag: 'user_activation', track_opens:'true'
  end

  # Company admin needs to approve this user
  def account_approval_needed(user, company)
    @user = user
    @company = company
    @emails = @company.admins.pluck(&:email)
    #puts "--- #{@user} #{@company} #{@company.admins.inspect}"
    mail to: @emails, subject: "Account approval needed",
        tag: 'user_approval_needed', track_opens:'true'
  end

  # company admin has just finished approving this user,
  # so notify the user
  def account_approval_done(user)
    @user = user
    mail to: @user.email, subject: "Account approved",
        tag: 'user_approval_done', track_opens:'true'
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset", tag: 'user_password_reset', track_opens:'true'
  end

  def added_by_admin(company, user)
    @user = user
    @company = company
    mail to: user.email, subject: "You have been added to #{company.name}",
        tag: 'user_added_by_admin', track_opens:'true'
  end

  def send_unassigned_report(managers, data)
    @data = data
    mail to: managers, subject: "Unassigned Listings Report",
        tag: 'unassigned_report', track_opens:'true'
  end
end
