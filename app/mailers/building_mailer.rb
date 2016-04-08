class BuildingMailer < ApplicationMailer

  def inaccuracy_reported(building, reporter)
    # data_enterers = building.company.data_enterers
    # if !data_enterers
    # 	data_enterers = building.company.admins
    # end
    @building = building
    @reporter = reporter
    mail to: 'info@myspacenyc.com',
    	subject: "Inaccuracy Reported for #{building.street_address}",
        reply_to: @reporter.email,
        tag: 'building_inaccuracy',
        track_opens:'true'
  end
end
