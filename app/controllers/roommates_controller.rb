class RoommatesController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => :create
  before_action :set_roommate, except: [:index, :new, :create, :filter]
  #autocomplete :landlord, :code, full: true
  etag { current_user.id }

  def index
    respond_to do |format|
      format.html do
        set_roommates
      end
    end
  end

  def show
  	@roommate = Roommate.find_unarchived(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "Sorry, that roommate is no longer available."
      redirect_to :action => 'index'
  end

  def filter
  end

  def download
  	ids = params[:roommate_ids].split(',')
  	@roommates = Roommate.where(id: ids)
  	
  	respond_to do |format|
      format.csv do
        #set_roommates_csv
        headers['Content-Disposition'] = "attachment; filename=\"roommates-list.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
      format.pdf do
      	render pdf: current_user.company.name + ' - Roommates - ' + Date.today.strftime("%b%d%Y"),
          template: "/roommates/roommates.pdf.erb",
          orientation: 'Landscape',
          layout:   "/layouts/pdf_layout.html"
      end
    end
  end

  # handles ajax call. uses latest data in modal
  def neighborhoods_modal
    @neighborhoods = Neighborhood.unarchived
    .where(city: current_user.office.administrative_area_level_2_short)
    .to_a
    .group_by(&:borough)
    
    respond_to do |format|
      format.js  
    end
  end

  def edit
  end

  def delete_modal
    respond_to do |format|
      format.js  
    end
  end

  # DELETE /residential_units/1
  # DELETE /residential_units/1.json
  def destroy
    @roommate.archive
    set_roommates
    respond_to do |format|
      format.html { redirect_to roommates_url, notice: 'Roommate was successfully deleted.' }
      format.json { head :no_content }
      format.js
    end
  end

  private
  	def set_roommate
  	end

  	def set_roommates
  		do_search
      #@roommates = custom_sort
      @roommates = @roommates.page params[:page]
  	end

  	def custom_sort
  	end

  	def do_search
  		@selected_neighborhoods = []
      if params[:neighborhood_ids]
        neighborhood_ids = params[:neighborhood_ids].split(",").select{|i| !i.empty?}
        @selected_neighborhoods = Neighborhood.where(id: neighborhood_ids)
      end

      @roommates = Roommate.search(params)
      @roommate_images = []
  	end

  	def set_roommates_csv
      #@landlords = Landlord.search_csv(params)
      #@landlords = custom_sort
    end

    def roommate_params
    	params.permit(:sort_by, :filter)

      # params.permit(:sort_by, :filter, :agent_filter, :active_only, :street_number, :route, 
      #   :neighborhood, :sublocality, :administrative_area_level_2_short, 
      #   :administrative_area_level_1_short, :postal_code, :country_short, :lat, :lng, :place_id, 
      #   :landlord => [:code, :name, :contact_name, :mobile, :office_phone, :fax, 
      #     :email, :website, :formatted_street_address, :notes, 
      #     :listing_agent_percentage, :listing_agent_id,
      #     :has_fee, :op_fee_percentage, :tp_fee_percentage, 
      #     :management_info, :key_pick_up_location, :update_source ])
    end

  end