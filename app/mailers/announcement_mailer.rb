class AnnouncementMailer < ApplicationMailer

	def send_broadcast(sender, recipients, note)
		@sender = sender
		@note = note
		mail to: recipients, subject: "[Announcement] "
	end

end
