class BuildingsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => :create
  before_action :set_building, except: [:index, :new, :create, :filter, :filter_listings, 
    :refresh_images, :neighborhood_options, :autocomplete_building_formatted_street_address]
  autocomplete :building, :formatted_street_address, full: true
  etag { current_user.id }
    
  # GET /buildings
  # GET /buildings.json
  def index
    set_buildings

    respond_to do |format|
      format.html
      format.csv do
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
    #fresh_when([@building, @building.images])
  end

  # GET /buildings/new
  def new
    @building = Building.new
    landlord_id = params[:landlord_id]
    if landlord_id && Landlord.where(landlord_id)
      @building.landlord_id = landlord_id
    end
  end

  # GET /buildings/1/edit
  def edit
  end

  # POST /buildings
  # POST /buildings.json
  def create
    @formatted_street_address = building_params[:building][:formatted_street_address]
    bldg_params = format_params_before_save(true)
    if @building.save(bldg_params)
      redirect_to @building
    else
      #puts "**** #{@user.errors.inspect}"
      # if this building has already been entered, redirect to that page
      @bldg = Building.find_by(formatted_street_address: @formatted_street_address)
      if @bldg
        flash[:info] = "Building already exists!"
        redirect_to @bldg
      else 
        # error
        render 'new'
      end
    end
  end

  # PATCH/PUT /buildings/1
  # PATCH/PUT /buildings/1.json
  def update
    if @building.update(format_params_before_save(false))
      flash[:success] = "Building updated!"
      redirect_to @building
    else
      render 'edit'
    end
  end

  # GET /refresh_images
  # ajax call
  def refresh_images
    #@building.increment_memcache_iterator
    respond_to do |format|
      format.js  
    end
  end

  # GET 
  # handles ajax call. uses latest data in modal
  def delete_modal
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
  def inaccuracy_modal
    respond_to do |format|
      format.js  
    end
  end

  # triggers email to staff notifying them of the inaccuracy
  def send_inaccuracy
    @building.inaccuracy_description = building_params[:inaccuracy_description]
    @building.send_inaccuracy_report(current_user)
    respond_to do |format|
      format.js { flash[:notice] = "Report submitted! Thank you." }
    end
  end

  def neighborhood_options
    @building = Building.new
    @building.sublocality = params[:sublocality]

    respond_to do |format|
      format.js  
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_building
      @building = Building.find_unarchived(params[:id])
      if @building.neighborhood
        @building.custom_neighborhood_id = @building.neighborhood.id
      end
      set_units
    end

    def set_units
      active_only = params[:active_only] == "true"
      @residential_units, @res_images = @building.residential_units(active_only)
      @residential_units = @residential_units.page params[:page]
      @commercial_units, @com_images = @building.commercial_units(active_only)
      @commercial_units = @commercial_units.page params[:page]
    end

    def set_buildings
      @buildings = Building.search(params[:page] || 0, 
        building_params[:filter], 
        building_params[:active_only])

      @buildings = custom_sort
      @buildings = @buildings.page params[:page]
      @bldg_imgs = Building.get_images(@buildings)
    end

    def custom_sort
      sort_column = building_params[:sort_by] || "formatted_street_address"
      sort_order = %w[asc desc].include?(building_params[:direction]) ? building_params[:direction] : "asc"
      # reset params so that view helper updates correctly
      params[:sort_by] = sort_column
      params[:direction] = sort_order
      @buildings = @buildings.order(sort_column + ' ' + sort_order)
      @buildings
    end

    def format_params_before_save(is_new)
      # get the whitelisted set of params, then arrange data
      # into the right format for our model
      param_obj = building_params
      param_obj[:building].each{ |k,v| param_obj[k] = v };

      param_obj.delete("building")
      # delete so that this field doesn't conflict with our foreign key
      @neighborhood_name = param_obj[:neighborhood]
      param_obj.delete("neighborhood")

      if is_new
        @building = Building.new(param_obj)
      end

      @building.company = current_user.company
      @building.neighborhood = @building.find_or_create_neighborhood(@neighborhood_name, param_obj[:sublocality], 
        param_obj[:administrative_area_level_2_short], param_obj[:administrative_area_level_1_short])

      param_obj
    end

    def clear_xhr_flash
      if request.xhr?
        # Also modify 'flash' to other attributes which you use in your common/flashes for js
        flash.discard
      end
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    # Need to take in additional params here. Can't rename them, or the geocode plugin
    # will not map to them correctly
    def building_params
      params.permit(:sort_by, :direction, :filter, :active_only, :street_number, :route, :intersection, 
        :neighborhood, 
        :sublocality, :administrative_area_level_2_short, 
        :administrative_area_level_1_short, 
        :postal_code, :country_short, :lat, :lng, :place_id, :landlord_id, :file,
        :building => [:formatted_street_address, :notes, :landlord_id, :user_id, :inaccuracy_description, 
          :pet_policy_id, :rental_term_id, :custom_rental_term, :file, :custom_amenities,
          :custom_utilities, :listing_agent_percentage, :listing_agent_id,
          :has_fee, :op_fee_percentage, :tp_fee_percentage, 
          :neighborhood_id, :neighborhood,
          :building_amenity_ids => [], images_files: [], :utility_ids => [] ])
    end
end
