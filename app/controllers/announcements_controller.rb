class AnnouncementsController < ApplicationController
	load_and_authorize_resource
  skip_load_resource :only => :create
  #before_action :set_announcement, only: [:index, :new, :create]
  autocomplete :building, :formatted_street_address, full: true

  def new
  	@announcement = Announcement.new
  end

	def create
		@announcement = Announcement.new(announcment_params)
    if @announcement.save
    	@announcement.broadcast(current_user.company)
    	flash[:info] = "Announcement sent!"
      redirect_to action: 'new'
    else
      # error
      render 'new'
    end
	end

	def index
		@announcements = Announcement.where("updated_at > ?", (Time.now - 2.days))
	end

	def get_units
		@listings = Unit.joins(:building).where("buildings.formatted_street_address = ?", params[:address])
	end

	private

		# def set_announcement
		# 	@announcement = Announcement.find(params[:id])
  #   rescue ActiveRecord::RecordNotFound
  #     flash[:warning] = "Sorry, that announcment was not found"
  #     redirect_to :action => 'index'
		# end

	def announcment_params
		# params.permit(:sort_by, :filter, :address, 
  #     :announcement => [:unit_id, :audience, :canned_response, :note])

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
