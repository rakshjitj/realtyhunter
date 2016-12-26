class UserMailer < ApplicationMailer
  def account_activation(user_id)
    @user = User.where(id: user_id).first
    mail to: @user.email, subject: "Account activation",
        tag: 'user_activation', track_opens:'true', reply_to: 'no-reply@myspacenyc.com'
  end

  # Company admin needs to approve this user
  def account_approval_needed(user_id, company_id)
    @user = User.where(id: user_id).first
    @company = Company.where(id: company_id).first
    @emails = @company.admins.pluck(&:email)
    #puts "--- #{@user} #{@company} #{@company.admins.inspect}"
    mail to: @emails, subject: "Account approval needed",
        tag: 'user_approval_needed', track_opens:'true', reply_to: 'no-reply@myspacenyc.com'
  end

  # company admin has just finished approving this user,
  # so notify the user
  def account_approval_done(user_id)
    @user = User.where(id: user_id).first
    mail to: @user.email, subject: "Account approved",
        tag: 'user_approval_done', track_opens:'true', reply_to: 'no-reply@myspacenyc.com'
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user_id, reset_token)
    @user = User.where(id: user_id).first
    @reset_token = reset_token
    mail to: @user.email, subject: "Password reset", tag: 'user_password_reset',
        track_opens:'true', reply_to: 'no-reply@myspacenyc.com'
  end

  def added_by_admin(company_id, user_id, reset_token)
    @user = User.where(id: user_id).first
    @company = Company.where(id: company_id).first
    @reset_token = reset_token
    mail to: @user.email, subject: "You have been added to #{@company.name}",
        tag: 'user_added_by_admin', track_opens:'true', reply_to: 'no-reply@myspacenyc.com'
  end

  # managers - list of email addresses
  # data - list of addresses
  def send_unassigned_report(managers, data)
    @data = data
    mail to: managers, subject: "Unassigned Listings Report",
        tag: 'unassigned_report', track_opens:'true', reply_to: 'no-reply@myspacenyc.com'
  end

  def send_primary_agent_removed_notification(user_id, listing_id)
    if !user_id || !listing_id
      puts "send_primary_agent_removed_notification: no data"
      return
    end

    @user = User.where(id: user_id).first

    @listing = ResidentialListing.joins(:unit).where('units.listing_id =?', listing_id).first
    if !@listing
      @listing = CommercialListing.joins(:unit).where('units.listing_id =?', listing_id).first
    end
    if !@listing
      @listing = SalesListing.joins(:unit).where('units.listing_id =?', listing_id).first
    end

    mail to: @user.email,
        subject: "You have been removed as primary agent from #{@listing.street_address_and_unit}",
        tag: 'primary_agent_removal', track_opens: 'true', reply_to: 'no-reply@myspacenyc.com'
  end

  def send_primary_agent_added_notification(user_id, listing_id)
    if !user_id || !listing_id
      puts "send_primary_agent_added_notification: no data"
      return
    end

    @user = User.where(id: user_id).first

    @listing = ResidentialListing.joins(:unit).where('units.listing_id =?', listing_id).first
    if !@listing
      @listing = CommercialListing.joins(:unit).where('units.listing_id =?', listing_id).first
    end
    if !@listing
      @listing = SalesListing.joins(:unit).where('units.listing_id =?', listing_id).first
    end

    mail to: @user.email,
        subject: "You have been added as primary agent on #{@listing.street_address_and_unit}",
        tag: 'primary_agent_addition', track_opens: 'true', reply_to: 'no-reply@myspacenyc.com'
  end
end
