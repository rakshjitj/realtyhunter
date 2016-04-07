class UnitMailer < ApplicationMailer

  def inaccuracy_reported(listing, reporter)
    # data_enterers = unit.building.company.data_enterers
    # if !data_enterers
    #   data_enterers = building.company.admins
    # end
    @listing = listing
    @reporter = reporter
    mail to: 'info@myspacenyc.com',
    	subject: "Inaccuracy Reported for #{listing.unit.building.street_address} ##{listing.unit.building_unit}",
    	from: @reporter.email
  end

  def commercial_inaccuracy_reported(listing, reporter)
    # data_enterers = unit.building.company.data_enterers
    # if !data_enterers
    #   data_enterers = building.company.admins
    # end
    @listing = listing
    @reporter = reporter
    mail to: 'info@myspacenyc.com',
    	subject: "Inaccuracy Reported for Commercial Unit: #{listing.unit.building.street_address}",
    	from: @reporter.email
  end

  def send_residential_listings(source_agent, listings, images, recipients, sub, msg)
    @listings = listings
    @source_agent = source_agent
    @message = msg
    @images = images
    mail to: recipients, subject: sub, from: @source_agent.email
  end

  def send_commercial_listings(source_agent, listings, images, recipients, sub, msg)
    @listings = listings
    @source_agent = source_agent
    @message = msg
    @images = images
    mail to: recipients, subject: sub, from: @source_agent.email
  end

  def send_sales_listings(source_agent, listings, images, recipients, sub, msg)
    @listings = listings
    @source_agent = source_agent
    @message = msg
    @images = images
    mail to: recipients, subject: sub, from: @source_agent.email
  end

  def send_residential_csv(user_id, params)
    @source_agent = User.find(user_id)
    attachments['Residential Listings.csv'] = ResidentialListing.to_csv(@source_agent, params)
    mail to: @source_agent.email, subject: "#{@source_agent.company.name} Residential Listings CSV"
  end

end
