class Announcement < ActiveRecord::Base
	default_scope { order("updated_at DESC") }
	belongs_to :unit

	enum audience: [:everyone, :managers, :agents]
	validates :audience, presence: true, inclusion: { 
    in: ['everyone', 'managers', 'agents'] }
	
	validates :canned_response, presence: true

	validates :note, allow_blank: true, length: {maximum: 140}

	def broadcast(company)
		client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']

		if Announcement.audiences[audience] == 'everyone'
			send_list = (company.managers + company.agents).map(&:mobile_phone_number)
		elsif Announcement.audiences[audience] == 'managers'
			send_list = company.managers.map(&:mobile_phone_number)
		elsif Announcement.audiences[audience] == 'agents'
			send_list = company.agents.map(&:mobile_phone_number)
		end

		# ignore any users with no phone numbers set
		send_list = ['8134952570', '6466965555', '(646) 623-7919']
		send_list = send_list.select{|i| i != ""}
		puts send_list.inspect

		body = 'RealtyHunter: testing out sending SMS. Please disregard! '
		body += '[' + canned_response + '] ' + unit.building.street_number + ' ' + unit.building.route
		if unit.building_unit
			body += ' #' + unit.building_unit
		end
		body += ' - ' + note
		body += ' - ' + current_user.name.split(' ')[0]

		send_list.each do |recipient|
	  	message = client.messages.create(
	  		from: ENV['TWILIO_SRC_TELEPHONE'], 
	  		to: recipient, 
	  		body: body)
	  end

	  self.update_attribute(:was_broadcast, true)
	end

end
