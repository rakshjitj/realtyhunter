class AnnouncementMailer < ApplicationMailer

	def send_broadcast(sender, recipients, note, canned_response, unit)
		@sender = sender
		@note = note
		@unit = unit
		@canned_response = canned_response
    mail to: recipients, from: sender, title: "[#{@canned_response}] #{@unit.building.street_number} #{@unit.building.route}"
	end

end
