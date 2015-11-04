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
    announcement_params[:announcement][:audience] = 'everyone'
		@announcement = Announcement.new(announcement_params[:announcement])
    if @announcement.save
    	@announcement.broadcast(current_user)
    	flash[:info] = "Announcement sent!"
      redirect_to action: 'new'
    else
      # error
      render 'new'
    end
	end

  def filter
    set_announcements
    respond_to do |format|
      format.js
    end
  end

	def index
    #set_announcements
    params[:limit] = 12 unless !params[:limit].blank?
    @announcements = Announcement.search(announcement_params)
	end

	def get_units
		@listings = Unit.joins(:building).where("buildings.formatted_street_address = ?", params[:address])
    @listings = @listings.select{|l| !l.building_unit.blank? }
	end

	private

    def set_announcements
      # params[:res_limit] = 10 unless !params[:res_limit].blank?
      # params[:com_limit] = 10 unless !params[:com_limit].blank?
      # params[:sales_limit] = 10 unless !params[:sales_limit].blank?
      # params[:event_limit] = 10 unless !params[:event_limit].blank?

      # # exclude events from all categories, except the last
      # @res_announcements = Announcement.search_residential(announcement_params)
      # @com_announcements = Announcement.search_commercial(announcement_params)
      # @sales_announcements = Announcement.search_sales(announcement_params)

      # # include events, even if they do not have a unit defined
      # @event_announcements = Announcement.search_events(announcement_params)
      
      params[:limit] = 12 unless !params[:limit].blank?
      @announcements = Announcement.search(announcement_params)
    end

  	def announcement_params
      
  		data = params.permit(
        :address, :limit, :res_limit, :com_limit, :sales_limit, :event_limit,
        :filter_address, :created_start, :created_end,
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
