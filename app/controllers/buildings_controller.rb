class BuildingsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: :create
  before_action :set_building, except: [:index, :new, :create, :filter, :filter_listings,
    :refresh_images, :neighborhood_options, :autocomplete_building_formatted_street_address]
  autocomplete :building, :formatted_street_address,
      where: {archived: false},
      full: true,
      extra_data: [:route, :street_number],
      display_value: :street_address

  include KnackInterface

  # GET /buildings
  # GET /buildings.json
  def index
    set_buildings

    respond_to do |format|
      format.html
      format.js
      format.csv do
        set_buildings_csv
        headers['Content-Disposition'] = "attachment; filename=\"buildings-list.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  # GET /filter_buildings
  # AJAX call
  def filter
    set_buildings
    respond_to do |format|
      format.js
    end
  end

  # AJAX call
  def filter_listings
    set_units
    respond_to do |format|
      format.js
    end
  end

  # GET /buildings/1
  # GET /buildings/1.json
  def show
    if !@building
      redirect_to buildings_url
    end
    set_units
  end

  # GET /buildings/new
  def new
    @building = Building.new
    landlord_id = params[:landlord_id]
    if landlord_id && Landlord.where("id = ?", landlord_id)
      @building.landlord_id = landlord_id
    end
    @landlords = current_user.company.landlords
      .where(archived: false)
      .order("code ASC")
      .collect {|l| [l.code, l.id]}
  end

  # GET /buildings/1/edit
  def edit
    @landlords = current_user.company.landlords
      .where(archived: false)
      .order("code ASC")
      .collect {|l| [l.code, l.id]}
  end

  # POST /buildings
  # POST /buildings.json
  def create
      # if this building has already been entered, redirect to that page
      #puts building_params[:building]
      @bldg = Building.where(
        street_number: building_params[:street_number],
        route: building_params[:route],
        archived: false
        ).first
      #puts "FOUND BLDG #{@bldg.inspect} #{building_params[:street_number]} #{building_params[:route]}"
      if @bldg
        flash[:info] = "Building already exists!"
        redirect_to @bldg
      else
        @formatted_street_address = building_params[:building][:formatted_street_address]
        bldg_params = format_params_before_save(true)
        if @building.save(bldg_params)
          Resque.enqueue(CreateBuilding, @building.id) # send to Knack
          # notify staff
          @building.send_creation_notification
          redirect_to @building
        else
          # error
          render 'new'
      end
    end
  end

  # PATCH/PUT /buildings/1
  # PATCH/PUT /buildings/1.json
  def update
    if @building.update(format_params_before_save(false).merge({updated_at: Time.now}))
      Resque.enqueue(UpdateBuilding, @building.id) # send to Knack
      flash[:success] = "Building updated!"
      redirect_to building_path(@building)
    else
      render 'edit'
    end
  end

  # GET /refresh_images
  # ajax call
  def refresh_images
    respond_to do |format|
      format.js
    end
  end

  # GET
  # handles ajax call. uses latest data in modal
  def delete_modal
    @params_copy = params
    @params_copy.delete('action')
    @params_copy.delete('controller')
    @params_copy.delete('id')
    # puts @params_copy.inspect
    respond_to do |format|
      format.js
    end
  end

  # DELETE /buildings/1
  # DELETE /buildings/1.json
  def destroy
    @building.archive
    set_buildings
    respond_to do |format|
      format.html { redirect_to buildings_url, notice: 'Building was successfully deleted.' }
      format.json { head :no_content }
      format.js
    end
  end

  # GET
  # handles ajax call. uses latest data in modal
  # def inaccuracy_modal
  #   respond_to do |format|
  #     format.js
  #   end
  # end

  # triggers email to staff notifying them of the inaccuracy
  def send_inaccuracy
    @building.send_inaccuracy_report(current_user,
        building_params[:building][:inaccuracy_description])
    flash[:success] = "Report submitted! Thank you."
    respond_to do |format|
      format.html { redirect_to @building }
      format.js {  }
    end
  end

  def neighborhood_options
    @building = Building.new
    @building.sublocality = params[:sublocality]

    respond_to do |format|
      format.js
    end
  end

  protected

   def correct_stale_record_version
      @building.reload
      params[:building].delete('lock_version')
   end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_building
      @building = Building.find_unarchived(params[:id])
      if @building.neighborhood
        @building.custom_neighborhood_id = @building.neighborhood.id
      end
    end

    def set_units
      if (!params[:status_listings])
        params[:status_listings] = 'active/pending'
      end
      @residential_units, @res_images, @res_bldg_images = @building.residential_units(params[:status_listings])
      @residential_units = @residential_units.page(params[:page]).per(25)
      @commercial_units, @com_images, @com_bldg_images = @building.commercial_units(params[:status_listings])
      # puts @com_bldg_images
      @commercial_units = @commercial_units.page(params[:page]).per(25)
    end

    def set_buildings_csv
      @buildings = Building.export_all(
          building_params[:filter],
          building_params[:status])
      @amenities = Building.get_amenities_from_buildings(@buildings)
      @utilities = Building.get_utilities_from_buildings(@buildings)
      @buildings = custom_sort
    end

    def set_buildings
      @buildings = Building.search(
        building_params[:filter],
        building_params[:status])

      @buildings = custom_sort
      @buildings = @buildings.page params[:page]
      @bldg_imgs = Building.get_images(@buildings)
    end

    def custom_sort
      sort_column = building_params[:sort_by] || "formatted_street_address".freeze
      sort_order = %w[asc desc].include?(building_params[:direction]) ? building_params[:direction] : "asc".freeze
      params[:sort_by] = sort_column
      params[:direction] = sort_order
      @buildings = @buildings.order("#{sort_column} #{sort_order}".freeze)
      @buildings
    end

    def format_params_before_save(is_new)
      # get the whitelisted set of params, then arrange data
      # into the right format for our model
      param_obj = building_params
      param_obj[:building].each{ |k,v| param_obj[k] = v };

      param_obj.delete("building".freeze)
      # delete so that this field doesn't conflict with our foreign key
      @neighborhood_name = param_obj[:neighborhood]
      param_obj.delete("neighborhood".freeze)

      if is_new
        @building = Building.new(param_obj)
      end

      @building.company = current_user.company
      @building.neighborhood = @building.find_or_create_neighborhood(@neighborhood_name, param_obj[:sublocality],
        param_obj[:administrative_area_level_2_short], param_obj[:administrative_area_level_1_short])

      param_obj
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    # Need to take in additional params here. Can't rename them, or the geocode plugin
    # will not map to them correctly
    def building_params
      params.permit(:sort_by, :direction, :page, :filter, :status, :status_listings, :street_number,
        :route, :intersection, :neighborhood,
        :sublocality, :administrative_area_level_2_short,
        :administrative_area_level_1_short, :inaccuracy_description, :request_price_drop,
        :postal_code, :country_short, :lat, :lng, :place_id, :landlord_id, :file,
        building: [:lock_version, :formatted_street_address, :notes, :landlord_id, :user_id,
          :inaccuracy_description, :pet_policy_id, :rental_term_id, :custom_rental_term, :file,
          :custom_amenities, :custom_utilities, :neighborhood_id, :neighborhood, :llc_name,
          building_amenity_ids: [], images_files: [], utility_ids: [] ])
    end
end
