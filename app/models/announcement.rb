class Announcement < ActiveRecord::Base
	default_scope { order("updated_at DESC") }
	belongs_to :unit
	belongs_to :user

	enum audience: [:everyone, :managers, :agents]
	validates :audience, presence: true, inclusion: { 
    in: ['everyone', 'managers', 'agents'] }
	
	validates :canned_response, presence: true

	validates :note, allow_blank: true, length: {maximum: 140}

  def self.search(params)
    entries = Announcement.joins(:user)
      .joins('left join units on units.id = announcements.unit_id')
      .joins('left join buildings on units.building_id = buildings.id')
      .joins('left join residential_listings on units.id = residential_listings.unit_id
left join commercial_listings on units.id = commercial_listings.unit_id
left join sales_listings on units.id = sales_listings.unit_id')
      .select('announcements.updated_at', 'canned_response', 'note', 'users.name AS sender_name',
        'buildings.street_number', 'buildings.route', 'units.building_unit', 
        'residential_listings.id as residential_listing_id',
        'commercial_listings.id as commercial_listing_id',
        'sales_listings.id as sales_listing_id', 'units.id as unit_id')
      .limit(params[:limit]).uniq

    if !params[:filter_address].blank?
      entries = entries.where("buildings.formatted_street_address = ?", params[:filter_address])
    end

    if !params[:created_start].blank?
      entries = entries.where('announcements.created_at > ?', params[:created_start]);
    end

    if !params[:created_end].blank?
      entries = entries.where('announcements.created_at < ?', params[:created_end]);
    end
    
    entries
  end

	def self.search_residential(params)
		entries = Announcement.joins(:user, unit: [:residential_listing, :building])
      .where('canned_response NOT ILIKE ? AND canned_response NOT ILIKE ?', '%event%', '%open house%')
      .select('announcements.updated_at', 'canned_response', 'note', 'units.id as unit_id',
        'buildings.street_number', 'buildings.route', 'users.name AS sender_name', 
        'units.building_unit', 'residential_listings.id as residential_listing_id')
      .limit(params[:res_limit])

    if !params[:filter_address].blank?
    	entries = entries.where("buildings.formatted_street_address = ?", params[:filter_address])
    end

    if params[:available_starting] || params[:available_before]
      if params[:available_starting] && !params[:available_starting].empty?
        @running_list = @running_list.where('available_by > ?', params[:available_starting]);
      end
      if params[:available_before] && !params[:available_before].empty?
        @running_list = @running_list.where('available_by < ?', params[:available_before]);
      end
    end

    if !params[:created_start].blank?
    	entries = entries.where('announcements.created_at > ?', params[:created_start]);
    end

    if !params[:created_end].blank?
    	entries = entries.where('announcements.created_at < ?', params[:created_end]);
    end

    entries
	end

	def self.search_commercial(params)
		entries = Announcement.joins(:user, unit: [:commercial_listing, :building])
      .where('canned_response NOT ILIKE ? AND canned_response NOT ILIKE ?', '%event%', '%open house%')
      .select('announcements.updated_at', 'canned_response', 'note', 'units.id as unit_id',
        'buildings.street_number', 'buildings.route', 'users.name AS sender_name', 
        'units.building_unit', 'commercial_listings.id as commercial_listing_id')
      .limit(params[:com_limit])

    if !params[:filter_address].blank?
    	entries = entries.where("buildings.formatted_street_address = ?", params[:filter_address])
    end

    if !params[:created_start].blank?
    	entries = entries.where('announcements.created_at > ?', params[:created_start]);
    end

    if !params[:created_end].blank?
    	entries = entries.where('announcements.created_at < ?', params[:created_end]);
    end

    entries
	end

	def self.search_sales(params)
		entries = Announcement.joins(:user, unit: [:sales_listing, :building])
      .where('canned_response NOT ILIKE ? AND canned_response NOT ILIKE ?', '%event%', '%open house%')
      .select('announcements.updated_at', 'canned_response', 'note', 'units.id as unit_id',
        'buildings.street_number', 'buildings.route',  'users.name AS sender_name',
        'units.building_unit', 'sales_listings.id as sales_listing_id')
      .limit(params[:sales_limit])

    if !params[:filter_address].blank?
    	entries = entries.where("buildings.formatted_street_address = ?", params[:filter_address])
    end

    if !params[:created_start].blank?
    	entries = entries.where('announcements.created_at > ?', params[:created_start]);
    end

    if !params[:created_end].blank?
    	entries = entries.where('announcements.created_at < ?', params[:created_end]);
    end

    entries
	end

	def self.search_events(params)
		entries = Announcement.joins(:user)
      .joins('left join units on units.id = announcements.unit_id')
      .joins('left join buildings on units.building_id = buildings.id')
      .joins('left join residential_listings on units.id = residential_listings.unit_id
left join commercial_listings on units.id = commercial_listings.unit_id
left join sales_listings on units.id = sales_listings.unit_id')
      .where('canned_response ILIKE ? or canned_response ILIKE ?', '%event%', '%open house%')
      .select('announcements.updated_at', 'canned_response', 'note', 'users.name AS sender_name',
        'buildings.street_number', 'buildings.route', 'units.building_unit', 
        'residential_listings.id as residential_listing_id',
        'commercial_listings.id as commercial_listing_id',
        'sales_listings.id as sales_listing_id', 'units.id as unit_id')
      .limit(params[:event_limit]).uniq

    if !params[:filter_address].blank?
    	entries = entries.where("buildings.formatted_street_address = ?", params[:filter_address])
    end

    if !params[:created_start].blank?
    	entries = entries.where('announcements.created_at > ?', params[:created_start]);
    end

    if !params[:created_end].blank?
    	entries = entries.where('announcements.created_at < ?', params[:created_end]);
    end
    
    entries
	end

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
