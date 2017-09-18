class BuildingMailer < ApplicationMailer
  def inaccuracy_reported(building_id, reporter_id, message)
    @building = Building.where(id: building_id).first
    @reporter = User.where(id: reporter_id).first
    @message = message
    mail to: ['info@myspacenyc.com', 'valentina@myspacenyc.com'],
        cc: @reporter.email,
    	subject: "Feedback provided for #{@building.street_address}",
        reply_to: @reporter.email,
        tag: 'building_inaccuracy',
        track_opens:'true'
  end

  def send_creation_notification(building_id)
    @building = Building.where(id: building_id).first
    mail to: ['uricohen646@gmail.com', 'rbujans@myspacenyc.com', 'aseinos@myspacenyc.com'],
      subject: "New building created: #{@building.street_address}",
        reply_to: ['uricohen646@gmail.com', 'aseinos@myspacenyc.com'],
        tag: 'building_created',
        track_opens:'true'
  end
end
