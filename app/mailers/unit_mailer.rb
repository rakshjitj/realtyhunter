class UnitMailer < ApplicationMailer

  def inaccuracy_reported(listing_id, reporter_id, message)
    @message = message
    @listing = ResidentialListing.where(id: listing_id).first
    if !@listing
      @listing = SalesListing.where(id: listing_id).first
    end

    @reporter = User.where(id: reporter_id).first

    mail to: 'info@myspacenyc.com',
    	subject: "Inaccuracy Reported for #{@listing.street_address_and_unit}",
    	reply_to: @reporter.email,
      tag: 'residential_inaccuracy',
      track_opens:'true'
  end

  def commercial_inaccuracy_reported(listing_id, reporter_id, message)
    @listing = CommercialListing.where(id: listing_id).first
    @reporter = User.where(id: reporter_id).first
    @message = message
    mail to: 'info@myspacenyc.com',
    	subject: "Inaccuracy Reported for Commercial Unit: #{@listing.street_address_and_unit}",
    	reply_to: @reporter.email,
      tag: 'commercial_inaccuracy',
      track_opens:'true'
  end

  def send_residential_listings(source_agent_id, listing_ids, recipients, sub, msg)
    @source_agent = User.where(id: source_agent_id).first
    @listings = ResidentialListing.listings_by_id(@source_agent, listing_ids)
    @images = ResidentialListing.get_images(@listings)
    @message = msg

    mail to: recipients, subject: sub, reply_to: @source_agent.email,
      tag: 'sent_residential_listings', track_opens:'true'
  end

  def send_commercial_listings(source_agent_id, listing_ids, recipients, sub, msg)
    @source_agent = User.where(id: source_agent_id).first
    @listings = CommercialListing.listings_by_id(@source_agent, listing_ids)
    @images = CommercialListing.get_images(@listings)
    @message = msg

    mail to: recipients, subject: sub, reply_to: @source_agent.email,
        tag: 'sent_commercial_listings', track_opens:'true'
  end

  def send_sales_listings(source_agent_id, listing_ids, recipients, sub, msg)
    @source_agent = User.where(id: source_agent_id).first
    @listings = SalesListing.listings_by_id(@source_agent, listing_ids)
    @images = SalesListing.get_images(@listings)
    @source_agent = source_agent
    @message = msg

    mail to: recipients, subject: sub, reply_to: @source_agent.email,
        tag: 'sent_sales_listings', track_opens:'true'
  end

  def send_stale_listings_report(managers, data)
    @data = data
    mail to: managers, subject: "Stale Listings Report",
        tag: 'stale_listings_report', track_opens:'true', reply_to: 'no-reply@myspacenyc.com'
  end

  def send_forced_syndication_report(managers, data)
    @data = data
    mail to: managers, subject: "Stale Listings Report",
        tag: 'stale_listings_report', track_opens:'true', reply_to: 'no-reply@myspacenyc.com'
  end

end
