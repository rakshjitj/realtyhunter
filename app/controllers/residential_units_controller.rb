class ResidentialUnitsController < ApplicationController
  load_and_authorize_resource
  before_action :set_residential_unit, except: [:new, :create, :index, :filter, 
    :print_list, :neighborhoods_modal, :features_modal, :refresh_images, 
    :remove_unit_feature, :remove_bldg_feature, :remove_neighborhood]
  etag { current_user.id }
  
  # GET /residential_units
  # GET /residential_units.json
  def index
    set_residential_units
    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"" + 
          current_user.name + " - Residential Listings.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  # AJAX call
  def filter
    set_residential_units
    respond_to do |format|
      format.js  
    end
  end

  # GET 
  # handles ajax call. uses latest data in modal
  def neighborhoods_modal
    @neighborhoods = Neighborhood.unarchived.where(
      city: current_user.office.administrative_area_level_2_short).all
    
    # if boroughs are defined for this area, organize the neighborhoods by boroughs
    boroughs = @neighborhoods.collect(&:borough).uniq
    @by_boroughs = {}
    if !boroughs.empty?
      @neighborhoods.each do |neighborhood|
        if !@by_boroughs.has_key? neighborhood.borough
          @by_boroughs[neighborhood.borough] = []
        end
        @by_boroughs[neighborhood.borough] << neighborhood
      end

      # alphabetize
      @by_boroughs.each do |b,n_array|
        n_array.sort_by!{|n| n.name.downcase}
      end
    end

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

  # GET /residential_units/1
  # GET /residential_units/1.json
  def show
    fresh_when([@residential_unit, @residential_unit.images])
  end

  # GET /residential_units/new
  def new
    @residential_unit = ResidentialUnit.new
    if params[:building_id]
      building = Building.find(params[:building_id])
      @residential_unit.building_id = building.id
    end
    
    @panel_title = "Add a listing"
  end

  # GET /residential_units/1/edit
  def edit
    @panel_title = "Edit listing"
  end

  # POST /residential_units
  # POST /residential_units.json
  def create
    @residential_unit = ResidentialUnit.new(residential_unit_params)
    if !@residential_unit.available_by?
      @residential_unit.available_by = Date.today
    end

    if @residential_unit.save
      redirect_to @residential_unit
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
    residential_unit_dup = @residential_unit.duplicate(
      residential_unit_params[:building_unit], residential_unit_params[:include_photos])
    if residential_unit_dup.valid?
      @residential_unit = residential_unit_dup
      render :js => "window.location.pathname = '#{residential_unit_path(@residential_unit)}'"
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
    new_end_date = residential_unit_params[:available_by]
    if new_end_date
      @residential_unit.take_off_market(new_end_date)
    end
    set_residential_units
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
    residential_units_no_pagination
    render pdf: current_user.name + ' Residential Listings',
      template: "/residential_units/print_list.pdf.erb",
      #disposition: "attachment",
      layout:   "/layouts/pdf_layout.html",
      orientation: 'Landscape',
      title: current_user.name + 'Residential Listings',
      default_header: false,
      header:  { right: '[page] of [topage]' },
      margin: { top: 0, bottom: 0, left: 0, right: 0}
  end

  def print_private
    #respond_to do |format|
    #  format.pdf do
        render pdf: current_user.name + ' - Residential - Private',
          template: "/residential_units/print_private.pdf.erb",
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
        render pdf: current_user.name + ' - Residential',
          template: "/residential_units/print_public.pdf.erb",
          #disposition: "attachment",
          layout:   "/layouts/pdf_layout.html"
    #  end
    #end
  end

  # PATCH/PUT /residential_units/1
  # PATCH/PUT /residential_units/1.json
  def update
    if @residential_unit.update(residential_unit_params)
      flash[:success] = "Unit successfully updated!"
      redirect_to @residential_unit
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

  # DELETE /residential_units/1
  # DELETE /residential_units/1.json
  def destroy
    @residential_unit.archive
    set_residential_units
    respond_to do |format|
      format.html { redirect_to residential_units_url, notice: 'Residential unit was successfully destroyed.' }
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
    @residential_unit.inaccuracy_description = residential_unit_params[:inaccuracy_description]
    @residential_unit.send_inaccuracy_report(current_user)
    respond_to do |format|
      format.js { flash[:notice] = "Report submitted! Thank you." }
    end
  end

  # GET /refresh_images
  # ajax call
  def refresh_images
    # invalidate cache
    @residential_unit.clear_cache
    respond_to do |format|
      format.js  
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_residential_unit
      @residential_unit = ResidentialUnit.find_unarchived(params[:id])
    end

    def set_residential_units
      do_search

      @map_infos = ResidentialUnit.set_location_data(@residential_units)
      @residential_units = Kaminari.paginate_array(@residential_units).page params[:page]
    end

    def residential_units_no_pagination
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

      @residential_units = ResidentialUnit.search(params, current_user, params[:building_id])
      @residential_units = custom_sort

      @residential_units
    end

    def custom_sort
      sort_column = params[:sort_by] || "updated_at"
      sort_order = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
      # if sorting by an actual db column, use order
      if ResidentialUnit.column_names.include?(params[:sort_by])
        @residential_units = @residential_units.order(sort_column + ' ' + sort_order)
      # otherwise call sort_by with our custom method
      else
        if sort_order == "asc"
          @residential_units = @residential_units.sort_by{|b| b.send(sort_column)}
        else
          @residential_units = @residential_units.sort_by{|b| b.send(sort_column)}.reverse
        end
      end
      @residential_units
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def residential_unit_params
      data = params[:residential_unit].permit(:building_unit, :rent, :available_by, :tenant_occupied,
        :access_info, :status, :has_fee, :open_house, :oh_exclusive,
        :building_id, :primary_agent_id, :listing_agent_id, :beds, :baths, :notes, :lease_start, :lease_end,
        :include_photos, :inaccuracy_description, :op_fee_percentage, :available_starting, :available_before,
        :tp_fee_percentage, :residential_amenity_ids => [])

      if data[:oh_exclusive] == "1"
        data[:oh_exclusive] = true
      else
        data[:oh_exclusive] = false
      end

      if data[:has_fee] == "1"
        data[:has_fee] = true
      else
        data[:has_fee] = false
      end

      # convert into a datetime obj
      if data[:available_by]
        data[:available_by] = Date::strptime(data[:available_by], "%m/%d/%Y")
      end

      data
    end
end
