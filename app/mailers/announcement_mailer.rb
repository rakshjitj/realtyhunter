class AnnouncementMailer < ApplicationMailer

	def send_broadcast(sender, recipients, note, canned_response, unit)
		@sender = sender
		@note = note
		@canned_response = canned_response
		if unit
			@unit = unit
	    mail to: recipients, subject: "[#{@canned_response}] #{@unit.building.street_number} #{@unit.building.route}"
	  else
	  	# event, with no location defined
	  	mail to: recipients, subject: "[#{@canned_response}]"
	  end
	end

end
