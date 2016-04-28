class AnnouncementMailer < ApplicationMailer

	def send_broadcast(sender_id, recipients, note)
		@sender = User.where(id: sender_id).first
		@note = note
		if note.length > 50
			title = note[0..50] + '...'
		else
			title = note
		end
		mail to: recipients, subject: "", tag: 'announcements', track_opens:'true'
	end

end
