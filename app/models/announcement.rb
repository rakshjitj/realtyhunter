class Announcement < ActiveRecord::Base
	default_scope { order("updated_at DESC") }
	belongs_to :unit
	belongs_to :user

	enum audience: [:everyone, :managers, :agents]
	validates :audience, presence: true, inclusion: { 
    in: ['everyone', 'managers', 'agents'] }
	
	validates :canned_response, presence: true

	validates :note, allow_blank: true, length: {maximum: 140}

	def broadcast(current_user)
		# NOTE: We've decided to go with email instead of texting for now, to save on costs.
		#client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']

		# if Announcement.audiences[audience] == 'everyone'
		# 	recipients = (company.managers + company.agents).map(&:email)
		# elsif Announcement.audiences[audience] == 'managers'
		# 	recipients = company.managers.map(&:email)
		# elsif Announcement.audiences[audience] == 'agents'
		# 	recipients = company.agents.map(&:email)
		# end
		# ignore any users with no phone numbers set
		#recipients = recipients.select{|i| i != ""}
		#puts recipients.inspect

		#recipients = ['myspaceupdates@myspacenyc.com']
		# NOTE: Disable company-wide emailing until fully debugged
		recipients = ['rbujans@myspacenyc.com'] #, current_user.email]
		
		# body = ''
		# #body = 'RealtyHunter: testing out sending SMS. Please disregard! '
		# body += '[' + canned_response + '] ' + unit.building.street_number + ' ' + unit.building.route
		# if unit.building_unit
		# 	body += ' #' + unit.building_unit
		# end
		# body += ' - ' + note
		# body += ' - ' + current_user.name.split(' ')[0]

		#recipients.each do |recipient|
	  	# message = client.messages.create(
	  	# 	from: ENV['TWILIO_SRC_TELEPHONE'], 
	  	# 	to: recipient, 
	  	# 	body: body)
	  #end

	  AnnouncementMailer.send_broadcast(current_user, recipients, note, canned_response, unit).deliver_now
	  self.update_attribute(:was_broadcast, true)
	end

end
