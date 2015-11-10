class AnnouncementMailer < ApplicationMailer

	def send_broadcast(sender, recipients, note, canned_response, unit)
		@sender = sender
		@note = note
		@canned_response = canned_response
		if unit
			@unit = unit
	    mail to: recipients, title: "[#{@canned_response}] #{@unit.building.street_number} #{@unit.building.route}" #, from: sender
	  else
	  	# event, with no location defined
	  	mail to: recipients, title: "[#{@canned_response}]"#, from: sender
	  end
	end

end
