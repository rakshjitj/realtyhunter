class UnitMailer < ApplicationMailer

  def inaccuracy_reported(listing, reporter)
    @listing = listing
    @reporter = reporter
    mail to: 'info@myspacenyc.com',
    	subject: "Inaccuracy Reported for #{listing.unit.building.street_address} ##{listing.unit.building_unit}",
    	reply_to: @reporter.email,
      tag: 'residential_inaccuracy',
      track_opens:'true'
  end

  def commercial_inaccuracy_reported(listing, reporter)
    @listing = listing
    @reporter = reporter
    mail to: 'info@myspacenyc.com',
    	subject: "Inaccuracy Reported for Commercial Unit: #{listing.unit.building.street_address}",
    	reply_to: @reporter.email,
      tag: 'commercial_inaccuracy',
      track_opens:'true'
  end

  def send_residential_listings(source_agent, listings, images, recipients, sub, msg)
    @listings = listings
    @source_agent = source_agent
    @message = msg
    @images = images
    mail to: recipients, subject: sub, reply_to: @source_agent.email,
      tag: 'sent_residential_listings', track_opens:'true'
  end

  def send_commercial_listings(source_agent, listings, images, recipients, sub, msg)
    @listings = listings
    @source_agent = source_agent
    @message = msg
    @images = images
    mail to: recipients, subject: sub, reply_to: @source_agent.email,
        tag: 'sent_commercial_listings', track_opens:'true'
  end

  def send_sales_listings(source_agent, listings, images, recipients, sub, msg)
    @listings = listings
    @source_agent = source_agent
    @message = msg
    @images = images
    mail to: recipients, subject: sub, reply_to: @source_agent.email,
        tag: 'sent_sales_listings', track_opens:'true'
  end

  def send_residential_csv(user_id, params)
    @source_agent = User.find(user_id)
    attachments['Residential Listings.csv'] = ResidentialListing.to_csv(@source_agent, params)
    mail to: @source_agent.email, subject: "#{@source_agent.company.name} Residential Listings CSV",
        tag: 'sent_residential_csv', track_opens:'true'
  end

end
