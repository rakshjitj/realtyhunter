class SalesListingsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: :create
  before_action :set_sales_listing, except: [:new, :create, :index, :filter,
    :print_list, :neighborhoods_modal, :features_modal, :neighborhood_options,
    :remove_unit_feature, :remove_bldg_feature, :remove_neighborhood, :fee_options]
  autocomplete :building, :formatted_street_address, full: true
  autocomplete :landlord, :code, full: true

  def index
    respond_to do |format|
      format.html do
        set_sales_listings
      end
      format.js do
        set_sales_listings
      end
      format.csv do
        set_sales_listings_csv
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

  def show
  end

  def new
    @sales_unit = SalesListing.new
    @sales_unit.unit = Unit.new
    @sales_unit.unit.building = Building.new
    if params[:building_id]
      building = Building.find(params[:building_id])
      @sales_unit.unit.building = building
    end

    @panel_title = "Add a listing"
  end

  def edit
    @panel_title = "Edit listing"
  end

  def create
    new_unit = nil
    new_bldg = nil
    @sales_unit = nil

    SalesListing.transaction do
      s_params = sales_listing_params[:sales_listing]
      u_params = s_params[:unit]
      #puts "BEFORE #{u_params.inspect}"
      u_params.delete('lock_version')
      #puts "AFTER #{u_params.inspect}"
      # find or create building
      new_bldg = Building.where(
        street_number: get_bldg_params[:street_number],
        route: get_bldg_params[:route]).first
      if !new_bldg
        new_bldg = Building.create(
          get_bldg_params.merge(
            company_id: current_user.company.id))
      end

      # create unit
      new_unit = Unit.new(u_params)
      new_unit.building = new_bldg
      s_params.delete('unit')
      if !new_unit.available_by?
        new_unit.available_by = Date.today
      end

      # create new listing
      @sales_unit = SalesListing.new(s_params)
      @sales_unit.unit = new_unit
    end

    if new_bldg.save && new_unit.save && @sales_unit.save
      redirect_to @sales_unit
    else
      #puts new_bldg.errors.messages
      #puts new_unit.errors.messages
      #puts @sales_unit.errors.messages
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

  def mark_app_submitted
    @sales_unit.unit.mark_app_submitted(current_user, 'sales', 'pending')
    @sales_unit.unit.set_rented_date
    set_sales_listings
    flash[:info] = 'Application submitted on ' +
      @sales_unit.unit.building.street_address + ' and announcement sent!'
    redirect_to request.referer
  end

  # GET
  # handles ajax call. uses latest data in modal
  # Modal collects info and prep unit to be taken off the market
  def print_modal
    respond_to do |format|
      format.js
    end
  end

  def print_private
    ids = params[:listing_ids].split(',')
    @neighborhood_group = SalesListing.listings_by_neighborhood(current_user, ids)

    render pdf: current_user.company.name + ' - Private Sales Listings - ' + Date.today.strftime("%b%d%Y"),
      template: "/sales_listings/print_private.pdf.erb",
      orientation: 'Landscape',
      layout:   "/layouts/pdf_layout.html"
  end

  # PATCH ajax
  # Takes a unit off the market
  def print_public
    ids = params[:listing_ids].split(',')
    @neighborhood_group = SalesListing.listings_by_neighborhood(current_user, ids)

    render pdf: current_user.company.name + ' - Public Sales Listings - ' + Date.today.strftime("%b%d%Y"),
      template: "/sales_listings/print_public.pdf.erb",
      orientation: 'Landscape',
      layout:   "/layouts/pdf_layout.html"
  end

  def update
    ret1 = nil
    ret2 = nil
    SalesListing.transaction do
      if @sales_unit.unit.primary_agent_id != sales_listing_params[:unit][:primary_agent_id].to_i
        Unit.update_primary_agent(
            residential_listing_params[:unit][:primary_agent_id],
            @sales_unit.unit.primary_agent_id,
            @sales_unit)
      end

      ret1 = @sales_unit.unit.update(sales_listing_params[:sales_listing][:unit].merge({updated_at: Time.now}))
      r_params = sales_listing_params[:sales_listing]
      r_params.delete('unit')
      ret2 = @sales_unit.update(r_params.merge({updated_at: Time.now}))
    end

    # update res
    if ret1 && ret2
      flash[:success] = "Unit successfully updated!"
      redirect_to sales_listing_path(@sales_unit)
    else
      render 'edit'
    end
  end

  # GET
  # handles ajax call. uses latest data in modal
  def delete_modal
    @params_copy = params
    @params_copy.delete('action')
    @params_copy.delete('controller')
    @params_copy.delete('id')
    respond_to do |format|
      format.js
    end
  end

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

  # sends listings info to clients
  def send_listings
    recipients = sales_listing_params[:recipients].split(/[\,,\s]/)
    sub = sales_listing_params[:title]
    msg = sales_listing_params[:message]
    listing_ids = sales_listing_params[:listing_ids].split(',')
    SalesListing.send_listings(current_user.id, listing_ids, recipients, sub, msg)

    respond_to do |format|
      format.js { flash[:success] = "Listings sent!"  }
    end
  end

  # PATCH
  # triggers email to staff notifying them of the inaccuracy
  def send_inaccuracy
    @sales_unit.send_inaccuracy_report(current_user, sales_listing_params[:inaccuracy_description])
    flash[:success] = "Report submitted! Thank you."
    respond_to do |format|
      format.html { redirect_to @sales_unit }
      format.js { }
    end
  end

  # ajax call
  def refresh_images
    respond_to do |format|
      format.js
    end
  end

  # ajax call
  def refresh_documents
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

  def neighborhood_options
    @sales_unit = SalesListing.new
    @sales_unit.unit = Unit.new
    @sales_unit.unit.building = Building.new
    @sales_unit.unit.building.sublocality = params[:sublocality]

    respond_to do |format|
      format.js
      format.json
    end
  end

  protected

   def correct_stale_record_version
    @sales_unit.reload
    params[:sales_listing].delete('lock_version')
   end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sales_listing
      @sales_unit = SalesListing.find_unarchived(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "Sorry, that listing is not active"
      redirect_to :action => 'index'
    end

    def set_sales_listings
      @neighborhoods = Neighborhood.unarchived
          .where(state: current_user.office.administrative_area_level_1_short)
          .to_a
          .group_by(&:borough)
      @building_amenities = BuildingAmenity.where(company: current_user.company)
      @unit_amenities = ResidentialAmenity.where(company: current_user.company)

      do_search
      @res_images = SalesListing.get_images(@sales_units)
      @sales_units = custom_sort

      @map_infos = SalesListing.set_location_data(@sales_units.to_a, @res_images)
      @sales_units = @sales_units.page params[:page]
    end

    # returns all data for export
    def set_sales_listings_csv
      @sales_units = SalesListing.export_all(current_user)
      @agents = Unit.get_primary_agents(@sales_units)
      @sales_units = custom_sort
    end

    def do_search
      # first, fix up parameters and set some view variables

      # default to searching for active units
      if !params[:status]
        params[:status] = "active".freeze
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
        @unit_features = SalesAmenity.where(id: feature_ids)
      end

      @bldg_features = []
      if params[:building_feature_ids]
        building_feature_ids = params[:building_feature_ids].split(",").select{|i| !i.empty?}
        @bldg_features = BuildingAmenity.where(id: building_feature_ids)
      end

      @sales_units = SalesListing.search(params, current_user, params[:building_id])
    end

    def custom_sort
      #puts "GOT #{params[:sort_by]} #{params[:direction]}"
      sort_column = params[:sort_by] || "updated_at".freeze
      sort_order = %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc".freeze
      params[:sort_by] = sort_column
      params[:direction] = sort_order
      # if sorting by an actual db column, use order
      if sort_column == 'bed_and_baths_sorter'.freeze
        @sales_units = @sales_units.order("beds #{sort_order}, baths #{sort_order}".freeze)
      else
        @sales_units = @sales_units.order("#{sort_column} #{sort_order}".freeze)
      end
      @sales_units
    end

    # pull only the building params out of our general params list
    def get_bldg_params
      param_names_list = [:street_number, :route, :intersection, :neighborhood,
        :sublocality, :administrative_area_level_2_short,
        :administrative_area_level_1_short, :postal_code, :country_short,
        :lat, :lng, :place_id, :neighborhood]

      bldg_params = {}
      param_names_list.each do |n|
        bldg_params[n] = sales_listing_params[n]
      end

      bldg_params[:formatted_street_address] = sales_listing_params[:sales_listing][:formatted_street_address]

      bldg_params
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sales_listing_params
      data = params.permit(
        :sort_by, :direction, :page, :filter,
        :beds, :baths, :include_photos, :inaccuracy_description,
        :available_starting, :available_before,
        :street_number, :route, :intersection,
        :neighborhood, :formatted_street_address,
        :sublocality, :administrative_area_level_2_short,
        :administrative_area_level_1_short,
        :postal_code, :country_short, :lat, :lng, :place_id,

        sales_listing: [
          :lock_version,
          :beds, :baths, :custom_amenities, :formatted_street_address,
          :listing_type, :percent_commission, :outside_broker_commission, :seller_name,
          :seller_phone, :seller_address, :year_built, :building_type, :lot_size,
          :building_size, :block_taxes, :lot_taxes, :water_sewer, :insurance,
          :school_district, :certificate_of_occupancy, :violation_search, :tenant_occupied,
          :internal_notes, :public_description,
          :floor, :total_room_count, :condition, :showing_instruction, :commission_amount, :cyof,
          :rented_date, :rlsny, :share_with_brokers, :favorites, :show, :expose_address,
          :unit => [:building_unit, :rent, :available_by, :access_info, :status, :exclusive,
            :building_id, :primary_agent_id, :listing_agent_id, :syndication_status],
          :sales_amenity_ids => []
          ])

      if data[:sales_listing][:unit]
        if !data[:sales_listing][:unit][:status].blank?
          data[:sales_listing][:unit][:status] = data[:sales_listing][:unit][:status].gsub(/\s+/, '_').downcase
        end

        # convert into a datetime obj
        if data[:sales_listing][:unit][:available_by] && !data[:sales_listing][:unit][:available_by].empty?
          data[:sales_listing][:unit][:available_by] = Date::strptime(data[:sales_listing][:unit][:available_by], "%m/%d/%Y")
        end
      end

      if !data[:include_photos].nil?
        if data[:include_photos] == "1"
          data[:include_photos] = true
        else
          data[:include_photos] = false
        end
      end

      if !data[:public_description].blank?
        data[:public_description] = data[:public_description].gsub(/&nbsp;/, ' ')
      end

      neighborhood_name = data[:neighborhood]
      data[:neighborhood] = Neighborhood.find_or_create_by(name: neighborhood_name)

      data
    end
end
