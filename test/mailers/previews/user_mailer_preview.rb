# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at
  # http://localhost:3000/rails/mailers/user_mailer/account_activation
  def account_activation
    user = User.first
    #user.activation_token = User.new_token
    UserMailer.account_activation(user.id)
  end

  # Preview this email at
  # http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    user = User.first
    user.create_reset_digest
    UserMailer.password_reset(user.id, user.reset_token)
  end

  def added_by_admin
    user = User.first
    company = Company.first
    user.create_reset_digest
    UserMailer.added_by_admin(company.id, user.id, user.reset_token)
  end
end
