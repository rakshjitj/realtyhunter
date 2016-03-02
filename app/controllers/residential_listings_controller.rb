class ResidentialListingsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: :create
  before_action :set_residential_listing, only: [:show, :edit, :duplicate_modal, :duplicate,
    :mark_app_submitted, :update, :delete_modal, :destroy,
    :inaccuracy_modal, :send_inaccuracy, :refresh_images, :refresh_documents]
  autocomplete :building, :formatted_street_address, full: true
  autocomplete :landlord, :code, full: true
  etag { current_user.id }

  def index
    respond_to do |format|
      format.html do
        set_residential_listings
      end
      format.js do
        set_residential_listings
      end
      format.csv do
        async_create_csv
        flash[:success] = "The CSV file will be emailed to you once it has been generated."
        params.delete('controller')
        params.delete('action')
        params.delete('format')
        redirect_to residential_listings_path(params)
      end
    end
  end

  # AJAX call
  def filter
    set_residential_listings
    respond_to do |format|
      format.js
      format.html do
        # catch-all
        redirect_to residential_listings_url
      end
    end
  end

  # GET /residential_units/1
  # GET /residential_units/1.json
  def show
  end

  # GET /residential_units/new
  def new
    @residential_unit = ResidentialListing.new
    @residential_unit.unit = Unit.new
    if params[:building_id]
      building = Building.find(params[:building_id])
      @residential_unit.unit.building_id = building.id
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
    ret1 = nil
    ResidentialListing.transaction do
      ret1 = Unit.new(residential_listing_params[:unit])
      r_params = residential_listing_params
      r_params.delete('unit')
      @residential_unit = ResidentialListing.new(r_params)
      @residential_unit.unit = ret1
    end

    if !ret1.available_by?
      ret1.available_by = Date.today
    end

    if ret1.save && @residential_unit.save
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
      residential_listing_params[:unit][:building_unit],
      residential_listing_params[:include_photos])

    if residential_unit_dup.valid?
      @residential_unit = residential_unit_dup
      render :js => "window.location.pathname = '#{residential_listing_path(@residential_unit)}'"
    else
      # TODO: not sure how to handle this best...
      flash[:warning] = "Duplication failed!"
      respond_to do |format|
        format.js
      end
    end
  end

  def mark_app_submitted
    @residential_unit.unit.mark_app_submitted(current_user, 'residential', 'pending')
    set_residential_listings
    flash[:info] = 'Application submitted on ' +
      @residential_unit.unit.building.street_address + ' and announcement sent!'
    redirect_to request.referer
  end

  # sends listings info to clients
  def send_listings
    recipients = residential_listing_params[:recipients].split(/[\,,\s]/)
    sub = residential_listing_params[:title]
    msg = residential_listing_params[:message]
    ids = residential_listing_params[:listing_ids].split(',')
    listings = ResidentialListing.listings_by_id(current_user, ids)
    images = ResidentialListing.get_images(listings)
    ResidentialListing.send_listings(current_user, listings, images, recipients, sub, msg)

    respond_to do |format|
      format.js { flash[:success] = "Listings sent!"  }
    end
  end

  def print_private
    ids = params[:listing_ids].split(',')
    @neighborhood_group = ResidentialListing.listings_by_neighborhood(current_user, ids)

    #respond_to do |format|
    #  format.pdf do
        render pdf: current_user.company.name + ' - Private Listings - ' + Date.today.strftime("%b%d%Y"),
          template: "/residential_listings/print_private.pdf.erb",
          orientation: 'Landscape',
          layout:   "/layouts/pdf_layout.html"
    #  end
    #end
  end

  # PATCH ajax
  # Takes a unit off the market
  def print_public
    ids = params[:listing_ids].split(',')
    @neighborhood_group = ResidentialListing.listings_by_neighborhood(current_user, ids)

    #respond_to do |format|
    #  format.pdf do
        render pdf: current_user.company.name + ' - Public Listings - ' + Date.today.strftime("%b%d%Y"),
          template: "/residential_listings/print_public.pdf.erb",
          orientation: 'Landscape',
          layout:   "/layouts/pdf_layout.html"
    #  end
    #end
  end

  # PATCH/PUT /residential_units/1
  # PATCH/PUT /residential_units/1.json
  def update
    ret1 = nil
    ret2 = nil
    ResidentialListing.transaction do
      ret1 = @residential_unit.unit.update(residential_listing_params[:unit].merge({updated_at: Time.now}))
      r_params = residential_listing_params
      r_params.delete('unit')
      ret2 = @residential_unit.update(r_params.merge({updated_at: Time.now}))
    end
    # update res
    if ret1 && ret2
      flash[:success] = "Unit successfully updated!"
      redirect_to residential_listing_path(@residential_unit, only_path: true)
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
    set_residential_listings
    respond_to do |format|
      format.html { redirect_to residential_listings_url, notice: 'Residential unit was successfully destroyed.' }
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
    @residential_unit.inaccuracy_description = residential_listing_params[:inaccuracy_description]
    @residential_unit.send_inaccuracy_report(current_user)
    respond_to do |format|
      format.js { flash[:success] = "Report submitted! Thank you." }
    end
  end

  # GET
  # ajax call
  def refresh_documents
    respond_to do |format|
      format.js
    end
  end

  # GET /refresh_images
  # ajax call
  def refresh_images
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

  def update_announcements
    @announcement_items = Announcement.search({limit: params[:limit]})
  end

  def assign_modal
    @listings = ResidentialListing.joins(:unit)
      .where("units.listing_id IN (?)", params[:listing_ids])
    respond_to do |format|
      format.js
    end

  end

  def assign
    @listings = ResidentialListing.joins(:unit)
      .where("units.listing_id IN (?)", params[:listing_ids].split(" "))
    @agent = User.find(params[:primary_agent_id])

    if @agent && @listings.length > 0
      @listings.each do |l|
        l.unit.update_attribute(:primary_agent_id, @agent.id)
      end
      flash[:success] = "Primary agent successfully assigned!"
      set_residential_listings
    end

    respond_to do |format|
      format.js
    end
  end

  def unassign_modal
    @listings = ResidentialListing.joins(:unit)
      .where("units.listing_id IN (?)", params[:listing_ids])
    respond_to do |format|
      format.js
    end

  end

  def unassign
    @listings = ResidentialListing.joins(:unit)
      .where("units.listing_id IN (?)", params[:listing_ids].split(" "))

    if @listings.length > 0
      @listings.each do |l|
        l.unit.update_attribute(:primary_agent_id, nil)
        l.unit.update_attribute(:primary_agent2_id, nil)
      end
      flash[:success] = "Primary agent successfully removed!"
      set_residential_listings
    end

    respond_to do |format|
      format.js
    end
  end

  protected

    def correct_stale_record_version
      @residential_unit.reload
      params[:residential_listing].delete('lock_version')
    end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_residential_listing
      @residential_unit = ResidentialListing.find_unarchived(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "Sorry, that listing is not active."
      redirect_to action: 'index'
    end

    def set_residential_listings
      @neighborhoods = Neighborhood.unarchived
          .where(state: current_user.office.administrative_area_level_1_short)
          .to_a
          .group_by(&:borough)

      @building_amenities = BuildingAmenity.where(company: current_user.company)
      @unit_amenities = ResidentialAmenity.where(company: current_user.company)

      do_search
      custom_sort
      # display all found listings on the map

      # note: we are loading waaaay more images now... monitor page load time
      @res_images = ResidentialListing.get_images(@residential_units)
      @map_infos = ResidentialListing.set_location_data(@residential_units.to_a, @res_images)
      # only get data + images for paginated responses
      @residential_units = @residential_units.page params[:page]
    end

    def async_create_csv
      # get IDs only and pass that along
      Resque.enqueue(GenerateResidentialCSV, current_user.id, params)
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

      @residential_units = ResidentialListing.search(params, current_user, params[:building_id])

      @announcement_items = Announcement.search({limit: 4})
    end

    def custom_sort
      # puts "GOT ---#{params.inspect} #{params[:sort_by]} --- #{params[:direction]}---"
      sort_column = params[:sort_by] || "updated_at"
      sort_order = %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
      # reset params so that view helper updates correctly
      params[:sort_by] = sort_column
      params[:direction] = sort_order
      # if sorting by an actual db column, use order
      @residential_units = @residential_units.order(sort_column + ' ' + sort_order)
      @residential_units
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def residential_listing_params
      data = params[:residential_listing].permit(
        :lock_version,
        :recipients, :title, :message, :listing_ids,
        :tenant_occupied, #:for_roomsharing,
        :beds, :baths, :notes, :description, :lease_start, :lease_end,
        :include_photos, :inaccuracy_description,
        :has_fee, :op_fee_percentage, :tp_fee_percentage,
        :available_starting, :available_before, :custom_amenities,
        :roomsharing_filter, :unassigned_filter, :primary_agent_id, :favorites, :show, :expose_address,
        :unit => [:building_unit, :rent, :available_by, :access_info, :status,
          :open_house, :oh_exclusive, :exclusive,
          :building_id, :primary_agent_id, :listing_agent_id ],
        :residential_amenity_ids => []
        )

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
        if !data[:unit][:available_by].blank?
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
