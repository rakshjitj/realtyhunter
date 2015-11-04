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
    # exclude events from all categories, except the last

		@res_announcements = Announcement.joins(:user, unit: [:residential_listing, :building])
      .where('canned_response NOT ILIKE ? AND canned_response NOT ILIKE ?', '%event%', '%open house%')
      .select('announcements.updated_at', 'canned_response', 'note', 'units.id as unit_id',
        'buildings.street_number', 'buildings.route', 'users.name AS sender_name',
        'units.building_unit').limit(10)

    @com_announcements = Announcement.joins(:user, unit: [:commercial_listing, :building])
      .where('canned_response NOT ILIKE ? AND canned_response NOT ILIKE ?', '%event%', '%open house%')
      .select('announcements.updated_at', 'canned_response', 'note', 'units.id as unit_id',
        'buildings.street_number', 'buildings.route', 'users.name AS sender_name', 
        'units.building_unit').limit(10)

    @sales_announcements = Announcement.joins(:user, unit: [:sales_listing, :building])
      .where('canned_response NOT ILIKE ? AND canned_response NOT ILIKE ?', '%event%', '%open house%')
      .select('announcements.updated_at', 'canned_response', 'note', 'units.id as unit_id',
        'buildings.street_number', 'buildings.route',  'users.name AS sender_name',
        'units.building_unit').limit(10)

    # include events, even if they do not have a unit defined
    @event_announcements = Announcement
      .joins(:user)
      .where('canned_response ILIKE ? or canned_response ILIKE ?', '%event%', '%open house%')
      .select('announcements.updated_at', 'canned_response', 'note', 'users.name AS sender_name')
      .limit(10)
      #.where("announcements.updated_at > ?", (Time.now - 2.days))
	end

	def get_units
		@listings = Unit.joins(:building).where("buildings.formatted_street_address = ?", params[:address])
    @listings = @listings.select{|l| !l.building_unit.blank? }
	end

	private

	def announcment_params
    
		data = params.permit(
      :address,
      announcement: [
        :audience, :unit, :unit_id, :canned_response, :note, :user])

    if !data[:address].blank? && data[:announcement][:unit_id].blank?
    	data[:announcement][:unit] = Unit.joins(:building)
        .where(building_unit: '')
    		.where("buildings.formatted_street_address = ?", data[:address]).first

    	data.delete('unit_id')
    end

    if data[:announcement][:audience]
      data[:announcement][:audience] = data[:announcement][:audience].downcase
    end

    if !data[:announcement][:user]
      data[:announcement][:user] = current_user
    end
		
    data
  end

end
