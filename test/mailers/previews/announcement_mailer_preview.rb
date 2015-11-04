# Preview all emails at http://localhost:3000/rails/mailers/announcement_mailer
class AnnouncementMailerPreview < ActionMailer::Preview
	def send_broadcast

    source_agent = User.first
    canned_response = "Application Pending"
    note = "LG #winning #ohYeahaaaahhh"
    unit = Unit.last
    recipients = ['myspaceupdates@myspacenyc.com']

    AnnouncementMailer.send_broadcast(
    	source_agent, recipients, note, canned_response, unit);
  end
end
