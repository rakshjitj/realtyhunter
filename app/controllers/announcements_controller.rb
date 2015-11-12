class AnnouncementsController < ApplicationController
	load_and_authorize_resource
  skip_load_resource :only => :create
  #before_action :set_announcement, only: [:index, :new, :create]
  autocomplete :building, :formatted_street_address, full: true

  def new
  	@announcement = Announcement.new
    get_units
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
    set_announcements
	end

	def get_units
    if !params[:address].blank?
  		@listings = Unit.joins(:building).where("buildings.formatted_street_address = ?", params[:address])
      @listings = @listings.select{|l| !l.building_unit.blank? }
    else
      @listings = []
    end
	end

  def delete_modal
    @announcement = Announcement.find(params[:id])
    respond_to do |format|
      format.js  
    end
  end

  def destroy
    @announcement = Announcement.find(params[:id])
    @announcement.delete
    
    # for residential page
    @announcement_items = Announcement.search({limit: 4})
    # for announcements page
    set_announcements

    respond_to do |format|
      format.html { redirect_to forms_careers_url, notice: 'Announcement was successfully inactivated.' }
      format.json { head :no_content }
      format.js
    end
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
      
  		data = params.permit(:id,
        :address, :unit_id, :limit, :res_limit, :com_limit, :sales_limit, :event_limit,
        :filter_address, :created_start, :created_end,
        announcement: [
          :id, :audience, :unit, :unit_id, :canned_response, :note, :user])

      # clicked on 'make announcement' link from residential_listings/show for example
      # if !data[:unit_id].blank?
      #   if !data[:announcement]
      #     data[:announcement] = {}
      #   end

      #   data[:announcement][:unit] = Unit.where(id: params[:unit_id])
      # end

      if !data[:address].blank? && data[:announcement] && data[:announcement][:unit_id].blank?
      	data[:announcement][:unit] = Unit.joins(:building)
          .where(building_unit: '')
      		.where("buildings.formatted_street_address = ?", data[:address]).first
        data.delete('unit_id')
        #data.delete('address')
      end

      if data[:announcement]
        if data[:announcement][:audience]
          data[:announcement][:audience] = data[:announcement][:audience].downcase
        end

        if !data[:announcement][:user]
          data[:announcement][:user] = current_user
        end
      end
  		
      #puts data
      data
    end

end
