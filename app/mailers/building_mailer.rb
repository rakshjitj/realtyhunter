class BuildingMailer < ApplicationMailer
  def inaccuracy_reported(building_id, reporter_id, message)
    @building = Building.where(id: building_id).first
    @reporter = User.where(id: reporter_id).first
    @message = message
    mail to: 'info@myspacenyc.com',
    	subject: "Inaccuracy Reported for #{@building.street_address}",
        reply_to: @reporter.email,
        tag: 'building_inaccuracy',
        track_opens:'true'
  end
end
