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
    announcment_params[:audience] = 'everyone'
		@announcement = Announcement.new(announcment_params)
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
		@announcements = Announcement.joins(unit: :building)
      .where("announcements.updated_at > ?", (Time.now - 2.days))
      .select('announcements.updated_at', 'canned_response', 'note', 
        'buildings.street_number', 'buildings.route', 
        'units.building_unit')
	end

	def get_units
		@listings = Unit.joins(:building).where("buildings.formatted_street_address = ?", params[:address])
	end

	private

	def announcment_params
    
		data = params.require(:announcement).permit(:unit_id, :audience, :canned_response, :note)
    if data[:address] && data[:unit_id].blank?
    	data[:unit] = Unit.joins(:building)
    		.where("buildings.formatted_street_address = ?", data[:address]).first
    	data.delete('unit_id')
    end

    if data[:audience]
      data[:audience] = data[:audience].downcase
    end
		
		#puts data[:announcement]
    data
  end

end
