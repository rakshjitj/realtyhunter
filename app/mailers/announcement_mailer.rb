class AnnouncementMailer < ApplicationMailer

	def send_broadcast(sender, recipients, note)
		@sender = sender
		@note = note
		if note.length > 50
			title = note[0..50] + '...'
		else
			title = note
		end
		mail to: recipients, subject: "", tag: 'announcements', track_opens:'true'
	end

end
