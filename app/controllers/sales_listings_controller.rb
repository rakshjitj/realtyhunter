class SalesListingsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: :create
  before_action :set_sales_listing, except: [:new, :create, :index, :filter, 
    :print_list, :neighborhoods_modal, :features_modal, 
    :remove_unit_feature, :remove_bldg_feature, :remove_neighborhood, :fee_options]
  autocomplete :building, :formatted_street_address, full: true
  autocomplete :landlord, :code, full: true
  etag { current_user.id }
  
  # GET /sales_units
  # GET /sales_units.json
  def index
    set_sales_listings
    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"" + 
          current_user.name + " - Sales Listings.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  # AJAX call
  def filter
    set_sales_listings
    respond_to do |format|
      format.js  
    end
  end

  # GET 
  # handles ajax call. uses latest data in modal
  def neighborhoods_modal
    @neighborhoods = Neighborhood.unarchived
    .where(city: current_user.office.administrative_area_level_2_short)
    .to_a
    .group_by(&:borough)
    
    # @neighborhoods.each do |borough, list|
    #   puts list.inspect
    # end

    respond_to do |format|
      format.js  
    end
  end

  # GET 
  # handles ajax call. uses latest data in modal
  def features_modal
    @building_amenities = BuildingAmenity.where(company: current_user.company)
    @unit_amenities = ResidentialAmenity.where(company: current_user.company)

    respond_to do |format|
      format.js  
    end
  end

  # GET /sales_units/1
  # GET /sales_units/1.json
  def show
    #fresh_when([@sales_unit, @sales_unit.images])
    #@sales_unit
  end

  # GET /sales_units/new
  def new
    @sales_unit = SalesListing.new
    @sales_unit.unit = Unit.new
    if params[:building_id]
      building = Building.find(params[:building_id])
      @sales_unit.unit.building_id = building.id
    end
    
    @panel_title = "Add a listing"
  end

  # GET /sales_units/1/edit
  def edit
    @panel_title = "Edit listing"
  end

  # POST /sales_units
  # POST /sales_units.json
  def create
    ret1 = Unit.new(sales_listing_params[:unit])
    r_params = sales_listing_params
    r_params.delete('unit')
    ret2 = SalesListing.new(r_params)
    ret2.unit = ret1
    
    if !ret1.available_by?
      ret1.available_by = Date.today
    end

    if ret1.save && ret2.save
      @sales_unit = ret2
      redirect_to @sales_unit
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
    sales_listing_dup = @sales_unit.duplicate(
      sales_listing_params[:unit][:building_unit], 
      sales_listing_params[:include_photos])

    if sales_listing_dup.valid?
      @sales_unit = sales_listing_dup
      render :js => "window.location.pathname = '#{sales_listing_path(@sales_unit)}'"
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
    new_end_date = sales_listing_params[:available_by]
    if new_end_date
      @sales_unit.take_off_market(new_end_date)
    end
    set_sales_listings
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

  def print_list
    sales_listings_no_pagination
    render pdf: current_user.name + ' sales_listing Listings',
      template: "/sales_listings/print_list.pdf.erb",
      #disposition: "attachment",
      layout:   "/layouts/pdf_layout.html",
      orientation: 'Landscape',
      title: current_user.name + 'sales_listing Listings',
      default_header: false,
      header:  { right: '[page] of [topage]' },
      margin: { top: 0, bottom: 0, left: 0, right: 0}
  end

  def print_private
    #respond_to do |format|
    #  format.pdf do
        render pdf: current_user.name + ' - sales_listing - Private',
          template: "/sales_listings/print_private.pdf.erb",
          #disposition: "attachment",
          layout:   "/layouts/pdf_layout.html"
    #  end
    #end
  end

  # PATCH ajax
  # Takes a unit off the market
  def print_public
    #respond_to do |format|
    #  format.pdf do
        render pdf: current_user.name + ' - sales_listing',
          template: "/sales_listings/print_public.pdf.erb",
          #disposition: "attachment",
          layout:   "/layouts/pdf_layout.html"
    #  end
    #end
  end

  # PATCH/PUT /sales_units/1
  # PATCH/PUT /sales_units/1.json
  def update
    ret1 = @sales_unit.unit.update(sales_listing_params[:unit].merge({updated_at: Time.now}))
    r_params = sales_listing_params
    r_params.delete('unit')
    ret2 = @sales_unit.update(r_params.merge({updated_at: Time.now}))

    # update res
    if ret1 && ret2
      flash[:success] = "Unit successfully updated!"
      redirect_to @sales_unit
    else
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

  # DELETE /sales_units/1
  # DELETE /sales_units/1.json
  def destroy
    @sales_unit.archive
    set_sales_listings
    respond_to do |format|
      format.html { redirect_to sales_listings_url, notice: 'sales_listing unit was successfully destroyed.' }
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
    @sales_unit.inaccuracy_description = sales_listing_params[:inaccuracy_description]
    @sales_unit.send_inaccuracy_report(current_user)
    respond_to do |format|
      format.js { flash[:notice] = "Report submitted! Thank you." }
    end
  end

  # GET /refresh_images
  # ajax call
  def refresh_images
    #puts "\n\n\n **** HELLO------- REFRESHING IMAGE #{@sales_unit} -- #{params.inspect}"
    respond_to do |format|
      format.js  
    end
  end

  def fee_options
    building = Building.find(params[:building_id])
    if building
      @landlord = building.landlord
    end
    respond_to do |format|
      format.js  
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sales_listing
      @sales_unit = SalesListing.find_unarchived(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "Sorry, that listing is not active."
      redirect_to :action => 'index'
    end

    def set_sales_listings
      do_search
      @sales_units = custom_sort

      @count_all = SalesListing.joins(:unit).where('units.archived = false').count
      @map_infos = SalesListing.set_location_data(@sales_units.to_a)
      @sales_unit = @sales_unit.page params[:page]
      @res_images = SalesListing.get_images(@sales_unit)
    end

    def sales_listings_no_pagination
      do_search
    end

    def do_search
      # first, fix up parameters and set some view variables

      # default to searching for active units
      if !params[:status]
        params[:status] = "active"
      end
      # parse neighborhood ids into strings for display in the view
      @selected_neighborhoods = []
      if params[:neighborhood_ids]
        neighborhood_ids = params[:neighborhood_ids].split(",").select{|i| !i.empty?}
        @selected_neighborhoods = Neighborhood.where(id: neighborhood_ids)
      end
      # parse feature ids into strings for display in the view
      @unit_features = []
      if params[:unit_feature_ids]
        feature_ids = params[:unit_feature_ids].split(",").select{|i| !i.empty?}
        @unit_features = ResidentialAmenity.where(id: feature_ids)
      end

      @bldg_features = []
      if params[:building_feature_ids]
        building_feature_ids = params[:building_feature_ids].split(",").select{|i| !i.empty?}
        @bldg_features = BuildingAmenity.where(id: building_feature_ids)
      end

      @sales_unit = SalesListing.search(params, current_user, params[:building_id])
    end

    def custom_sort
      #puts "GOT #{params[:sort_by]} #{params[:direction]}"
      sort_column = params[:sort_by] || "updated_at"
      sort_order = %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
      # reset params so that view helper updates correctly
      params[:sort_by] = sort_column
      params[:direction] = sort_order
      # if sorting by an actual db column, use order
      @sales_unit = @sales_unit.order(sort_column + ' ' + sort_order)
      @sales_unit
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sales_listing_params
      data = params[:sales_listing].permit(:tenant_occupied,
        :beds, :baths, :notes, :description, :lease_start, :lease_end,
        :include_photos, :inaccuracy_description, 
        :has_fee, :op_fee_percentage, :tp_fee_percentage, 
        :available_starting, :available_before,   
        :unit => [:building_unit, :rent, :available_by, :access_info, :status, 
          :open_house, :oh_exclusive, 
          :building_id, :primary_agent_id, :listing_agent_id ],
        :sales_amenity_ids => [])

      if data[:unit]
        if data[:unit][:oh_exclusive] == "1"
          data[:unit][:oh_exclusive] = true
        else
          data[:unit][:oh_exclusive] = false
        end

        if data[:unit][:status]
          data[:unit][:status] = data[:unit][:status].downcase
        end

        # convert into a datetime obj
        if data[:unit][:available_by] && !data[:unit][:available_by].empty?
          data[:unit][:available_by] = Date::strptime(data[:unit][:available_by], "%m/%d/%Y")
        end
      end

      if !data[:has_fee].nil? 
        if data[:has_fee] == "1"
          data[:has_fee] = true
        else
          data[:has_fee] = false
        end
      end

      if !data[:include_photos].nil?
        if data[:include_photos] == "1"
          data[:include_photos] = true
        else
          data[:include_photos] = false
        end
      end

      data
    end
end