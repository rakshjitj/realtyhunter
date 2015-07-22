class UnitMailer < ApplicationMailer

  def inaccuracy_reported(unit, reporter)
    # data_enterers = unit.building.company.data_enterers
    # if !data_enterers
    #   data_enterers = building.company.admins
    # end
    @unit = unit
    @reporter = reporter
    mail to: 'info@myspacenyc.com', #data_enterers.map(&:email), 
    	subject: "Inaccuracy Reported for #{unit.building.street_address} ##{unit.building_unit}", 
    	from: @reporter.email
  end

  def commercial_inaccuracy_reported(unit, reporter)
    # data_enterers = unit.building.company.data_enterers
    # if !data_enterers
    #   data_enterers = building.company.admins
    # end
    @unit = unit
    @reporter = reporter
    mail to: 'info@myspacenyc.com', #data_enterers.map(&:email), 
    	subject: "Inaccuracy Reported for Commercial Unit: #{unit.building.street_address}", 
    	from: @reporter.email
  end
end
