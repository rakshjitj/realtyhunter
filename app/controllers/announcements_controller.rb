class AnnouncementsController < ApplicationController
	load_and_authorize_resource
  skip_load_resource :only => :create
  #before_action :set_announcement, only: [:index, :new, :create]
  autocomplete :building, :formatted_street_address, full: true

  def new
  	@announcement = Announcement.new
  end

	def create
    # NOTE: for now, we've decided to just email myspaceupdates google group.
    # This means 'everyone' will be getting all updates, all the time.
    announcment_params[:announcement][:audience] = 'everyone'
		@announcement = Announcement.new(announcment_params[:announcement])
    if @announcement.save
    	@announcement.broadcast(current_user)
    	flash[:info] = "Announcement sent!"
      redirect_to action: 'new'
    else
      # error
      render 'new'
    end
	end

	def index
    if !params[:res_limit]
      params[:res_limit] = 10
    end
    if !params[:com_limit]
      params[:com_limit] = 10
    end
    if !params[:sales_limit]
      params[:sales_limit] = 10
    end
    if !params[:event_limit]
      params[:event_limit] = 10
    end

    # exclude events from all categories, except the last

		@res_announcements = Announcement.joins(:user, unit: [:residential_listing, :building])
      .where('canned_response NOT ILIKE ? AND canned_response NOT ILIKE ?', '%event%', '%open house%')
      .select('announcements.updated_at', 'canned_response', 'note', 'units.id as unit_id',
        'buildings.street_number', 'buildings.route', 'users.name AS sender_name', 
        'units.building_unit', 'residential_listings.id as residential_listing_id')
      .limit(announcment_params[:res_limit])

    @com_announcements = Announcement.joins(:user, unit: [:commercial_listing, :building])
      .where('canned_response NOT ILIKE ? AND canned_response NOT ILIKE ?', '%event%', '%open house%')
      .select('announcements.updated_at', 'canned_response', 'note', 'units.id as unit_id',
        'buildings.street_number', 'buildings.route', 'users.name AS sender_name', 
        'units.building_unit', 'commercial_listings.id as commercial_listing_id')
      .limit(announcment_params[:com_limit])

    @sales_announcements = Announcement.joins(:user, unit: [:sales_listing, :building])
      .where('canned_response NOT ILIKE ? AND canned_response NOT ILIKE ?', '%event%', '%open house%')
      .select('announcements.updated_at', 'canned_response', 'note', 'units.id as unit_id',
        'buildings.street_number', 'buildings.route',  'users.name AS sender_name',
        'units.building_unit', 'sales_listings.id as sales_listing_id')
      .limit(announcment_params[:sales_limit])

    # include events, even if they do not have a unit defined
    @event_announcements = Announcement
      .joins(:user)
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
      .limit(announcment_params[:event_limit]).uniq

      #.where("announcements.updated_at > ?", (Time.now - 2.days))
	end

	def get_units
		@listings = Unit.joins(:building).where("buildings.formatted_street_address = ?", params[:address])
    @listings = @listings.select{|l| !l.building_unit.blank? }
	end

	private

	def announcment_params
    
		data = params.permit(
      :address, :res_limit, :com_limit, :sales_limit, :event_limit,
      announcement: [
        :audience, :unit, :unit_id, :canned_response, :note, :user])

    if !data[:address].blank? && data[:announcement] && data[:announcement][:unit_id].blank?
    	data[:announcement][:unit] = Unit.joins(:building)
        .where(building_unit: '')
    		.where("buildings.formatted_street_address = ?", data[:address]).first

    	data.delete('unit_id')
    end

    if data[:announcement]
      if data[:announcement][:audience]
        data[:announcement][:audience] = data[:announcement][:audience].downcase
      end

      if !data[:announcement][:user]
        data[:announcement][:user] = current_user
      end
    end
		
    data
  end

end
