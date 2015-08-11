class UnitMailer < ApplicationMailer

  def inaccuracy_reported(listing, reporter)
    # data_enterers = unit.building.company.data_enterers
    # if !data_enterers
    #   data_enterers = building.company.admins
    # end
    @listing = listing
    @reporter = reporter
    mail to: 'info@myspacenyc.com', #data_enterers.map(&:email), 
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
    mail to: 'info@myspacenyc.com', #data_enterers.map(&:email), 
    	subject: "Inaccuracy Reported for Commercial Unit: #{listing.unit.building.street_address}", 
    	from: @reporter.email
  end
end
