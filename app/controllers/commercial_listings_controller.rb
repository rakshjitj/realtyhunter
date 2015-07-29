class CommercialListingsController < ApplicationController
  load_and_authorize_resource
  before_action :set_commercial_listing, except: [:new, :create, :index, :filter, 
    :neighborhoods_modal, :features_modal, :refresh_images ] #:update_subtype
  etag { current_user.id }

  # GET /commercial_units
  # GET /commercial_units.json
  def index
    set_commercial_listings
    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"" + 
          current_user.name + " - Commercial Listings.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def filter
    set_commercial_listings
    respond_to do |format|
      format.js  
    end
  end

  # GET /commercial_units/1
  # GET /commercial_units/1.json
  def show
    #fresh_when([@commercial_unit, @commercial_unit.images])
    #respond_to do |format|
      #format.html
      #format.js
    #   format.pdf do
    #     render pdf: current_user.name + ' Commercial - Private',
    #       template: "/commercial_units/print_private.pdf.erb",
    #       layout:   "/layouts/pdf_layout.html"
    #   end
    # end
  end

  # GET /commercial_units/new
  def new
    @commercial_unit = CommercialListing.new
    @commercial_unit.unit = Unit.new
    @property_sub_types = CommercialPropertyType.subtypes_for("Retail", current_user.company)
    if params[:building_id]
      building = Building.find(params[:building_id])
      @commercial_unit.unit.building_id = building.id
    end

    @panel_title = "Add a listing"
    set_property_types
  end

  # GET /commercial_units/1/edit
  def edit
    @panel_title = "Edit listing"
    set_property_types
  end

  def update_subtype
    ptype = params[:property_type]
    @property_sub_types = CommercialPropertyType.subtypes_for(ptype, current_user.company)
    puts "\n\n\n **** #{@property_sub_types.inspect}"
    respond_to do |format|
      format.js  
    end
  end

  # POST /commercial_units
  # POST /commercial_units.json
  def create
    ret1 = Unit.new(commercial_listing_params[:unit])
    c_params= commercial_listing_params
    c_params.delete('unit')
    ret2 = CommercialListing.new(c_params)
    ret2.unit = ret1

    if !ret1.available_by?
      ret1.available_by = Date.today
    end

    if ret1.save! && ret2.save!
      @commercial_unit = ret2
      redirect_to @commercial_unit
    else
      render 'new'
    end
  end

  # GET 
  # handles ajax call. uses latest data in modal
  def duplicate_modal
    respond_to do |format|
      format.js  
    end
  end

  # POST
  # handles ajax call. uses latest data in modal
  def duplicate
    commercial_unit_dup = @commercial_unit.duplicate(
      commercial_listing_params[:unit][:building_unit], 
      commercial_listing_params[:include_photos])
    
    if commercial_unit_dup.valid?
      @commercial_unit = commercial_unit_dup
      render :js => "window.location.pathname = '#{commercial_listing_path(@commercial_unit)}'"
    else
      # TODO: not sure how to handle this best...
      flash[:warning] = "Duplication failed!"
      respond_to do |format|
        format.js  
      end
    end
  end

  # GET 
  # handles ajax call. uses latest data in modal
  # Modal collects info and prep unit to be taken off the market
  def take_off_modal
    respond_to do |format|
      format.js  
    end
  end

  # PATCH ajax
  # Takes a unit off the market
  def take_off
    new_end_date = commercial_listing_params[:available_by]
    if new_end_date
      @commercial_unit.take_off_market(new_end_date)
    end
    set_commercial_listing
    respond_to do |format|
      format.js  
    end
  end

  # GET
  # handles ajax call. uses latest data in modal
  # Modal collects info and prep unit to be taken off the market
  def print_modal
    respond_to do |format|
      format.js  
    end
  end

  #def print_private
    #respond_to do |format|
    #  format.pdf do
        # render pdf: current_user.name + ' Commercial - Private',
        #   template: "/commercial_units/print_private.pdf.erb",
        #   #disposition: "attachment",
        #   layout:   "/layouts/pdf_layout.html"
    #  end
    #end
  #end

  # PATCH/PUT /commercial_units/1
  # PATCH/PUT /commercial_units/1.json
  def update
    ret1 = @commercial_unit.unit.update(commercial_listing_params[:unit])
    c_params = commercial_listing_params
    c_params.delete('unit')
    ret2 = @commercial_unit.update(c_params)
    if ret1 && ret2
      flash[:success] = "Unit successfully updated!"
      redirect_to @commercial_unit
    else
      set_property_types
      render 'edit'
    end
  end

  # GET 
  # handles ajax call. uses latest data in modal
  def delete_modal
    respond_to do |format|
      format.js  
    end
  end

  # DELETE /commercial_units/1
  # DELETE /commercial_units/1.json
  def destroy
    @commercial_unit.archive
    set_commercial_listings
    respond_to do |format|
      format.html { redirect_to commercial_units_url, notice: 'Commercial unit was successfully destroyed.' }
      format.json { head :no_content }
      format.js
    end
  end

  # GET 
  # handles ajax call. uses latest data in modal
  def inaccuracy_modal
    respond_to do |format|
      format.js  
    end
  end

  # PATCH
  # triggers email to staff notifying them of the inaccuracy
  def send_inaccuracy
    @commercial_unit.inaccuracy_description = commercial_listing_params[:inaccuracy_description]
    @commercial_unit.send_inaccuracy_report(current_user)
    respond_to do |format|
      format.js { flash[:notice] = "Report submitted! Thank you." }
    end
  end

  # GET /refresh_images
  # ajax call
  def refresh_images
    # invalidate cache
    #@commercial_unit.clear_cache
    respond_to do |format|
      format.js  
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commercial_listing
      @commercial_unit = CommercialListing.find_unarchived(params[:id])
    end

    def set_commercial_listings
      do_search
      @count_all = CommercialListing.all.count
      @map_infos = CommercialListing.set_location_data(@commercial_units)
      @commercial_units = @commercial_units.page params[:page]
    end

    def commercial_units_no_pagination
      do_search
    end

    def do_search
      # default to searching for active units
      if !params[:status]
        params[:status] = "active"
      end

      @commercial_units, @com_images = CommercialListing.search(params, current_user, params[:building_id])
      @commercial_units = custom_sort
    end

    def set_property_types
      @property_types = current_user.company.commercial_property_types
      .select(:property_type).order('property_type ASC').distinct

      if @commercial_unit.commercial_property_type
        @property_sub_types = CommercialPropertyType.subtypes_for(
          @commercial_unit.commercial_property_type.property_type, current_user.company)
      end
    end

    def custom_sort
      sort_column = params[:sort_by] || "updated_at"
      sort_order = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
      # reset params so that view helper updates correctly
      params[:sort_by] = sort_column
      params[:direction] = sort_order
      # if sorting by an actual db column, use order
      if CommercialListing.column_names.include?(params[:sort_by])
        @commercial_units = @commercial_units.order(sort_column + ' ' + sort_order)
      # otherwise call sort_by with our custom method
      else
        # TODO
        # if sort_order == "asc"
        #   @commercial_units = @commercial_units.sort_by{|b| b.send(sort_column)}
        # else
        #   @commercial_units = @commercial_units.sort_by{|b| b.send(sort_column)}.reverse
        # end
      end
      @commercial_units
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def commercial_listing_params
      if params[:commercial_property_type_id]
        params[:commercial_listing][:commercial_property_type_id] = params[:commercial_property_type_id]
      end

      data = params[:commercial_listing].permit(:building_unit, :rent, :status, :available_by, 
        :status, :building_id, :user_id, :include_photos,
        :sq_footage, :floor, :building_size, :build_to_suit, :minimum_divisible, :maximum_contiguous,
        :lease_type, :is_sublease, :property_description, :location_description,
        :construction_status, :no_parking_spaces, :pct_procurement_fee, :lease_term_months,
        :rate_is_negotiable, :total_lot_size, :property_type, :commercial_property_type_id,
        :commercial_unit_id, :inaccuracy_description,
        :unit => [:building_unit, :rent, :available_by, :access_info, :status, :open_house, :oh_exclusive, 
          :building_id, :primary_agent_id, :listing_agent_id ],
        )

      if data[:unit][:oh_exclusive] == "1"
        data[:unit][:oh_exclusive] = true
      else
        data[:unit][:oh_exclusive] = false
      end
      
      # convert into a datetime obj
      if data[:unit][:available_by] && !data[:unit][:available_by].empty?
        data[:unit][:available_by] = Date::strptime(data[:unit][:available_by], "%m/%d/%Y")
      end

      data
    end
end