class BuildingMailer < ApplicationMailer

  def inaccuracy_reported(building, reporter)
    company_admins = building.company.admins
    @building = building
    @reporter = reporter
    mail to: company_admins.map(&:email), 
    	subject: "Inaccuracy Reported for #{building.street_address}", from: @reporter.email
  end
end
