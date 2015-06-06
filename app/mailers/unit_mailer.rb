class UnitMailer < ApplicationMailer

  def inaccuracy_reported(unit, reporter)
    company_admins = unit.building.company.admins
    @unit = unit
    @reporter = reporter
    mail to: company_admins.map(&:email), 
    	subject: "Inaccuracy Reported for #{unit.building.street_address} ##{unit.building_unit}", 
    	from: @reporter.email
  end

  def commercial_inaccuracy_reported(unit, reporter)
    company_admins = unit.building.company.admins
    @unit = unit
    @reporter = reporter
    mail to: company_admins.map(&:email), 
    	subject: "Inaccuracy Reported for Commercial Unit: #{unit.building.street_address}", 
    	from: @reporter.email
  end
end
