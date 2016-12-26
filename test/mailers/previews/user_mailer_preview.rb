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

  def added_by_admin
    user = User.first
    company = Company.first
    user.create_reset_digest
    UserMailer.added_by_admin(company.id, user.id, user.reset_token)
  end

  def send_primary_agent_removed_notification
    user = User.last
    listing = ResidentialListing.joins(:unit)
      .select('residential_listings.*', 'units.listing_id')
      .last
    UserMailer.send_primary_agent_removed_notification(user.id, listing.listing_id)
  end

  def send_primary_agent_added_notification
    user = User.last
    listing = ResidentialListing.joins(:unit)
      .select('residential_listings.*', 'units.listing_id')
      .last

    UserMailer.send_primary_agent_added_notification(user.id, listing.listing_id)
  end

end
