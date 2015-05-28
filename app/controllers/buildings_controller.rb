class BuildingsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => :create
  before_action :set_building, except: [:index, :new, :create, :filter]

  # GET /buildings
  # GET /buildings.json
  def index
    @buildings = Building.order(sort_order).paginate(:page => params[:page])
    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"building-list.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end

  end
  
  # GET /filter_buildings
  # AJAX call
  def filter
    set_buildings
  end

  # GET /buildings/1
  # GET /buildings/1.json
  def show
  end

  # GET /buildings/new
  def new
    @building = Building.new
  end

  # GET /buildings/1/edit
  def edit
  end

  # POST /buildings
  # POST /buildings.json
  def create
    # get the whitelisted set of params, then arrange data
    # into the right format for our model
    param_obj = building_params
    param_obj[:notes] = param_obj[:building][:notes]
    param_obj[:formatted_street_address] = param_obj[:building][:formatted_street_address]
    param_obj[:landlord_id] = param_obj[:building][:landlord_id]
    param_obj.delete("building")
    
    # delete so that this field doesn't conflict with our foreign key
    @neighborhood_name = param_obj[:neighborhood]
    param_obj.delete("neighborhood")

    @building = Building.new(param_obj)
    @building.company = current_user.company
    # TODO: once this data has been populate enough by google
    # revert to regular save  #.save
    if @building.save_and_create_neighborhood(@neighborhood_name, param_obj[:sublocality], 
      param_obj[:administrative_area_level_2_short], param_obj[:administrative_area_level_1_short])
      redirect_to @building
    else
      #puts "**** #{@user.errors.inspect}"
      @bldg = Building.find_by(formatted_street_address: param_obj[:formatted_street_address])
      if @bldg
        flash[:info] = "Building already exists!"
        redirect_to @bldg
      else 
        render 'new'
      end
    end
  end

  # PATCH/PUT /buildings/1
  # PATCH/PUT /buildings/1.json
  def update
    respond_to do |format|
      if @building.update(building_params)
        format.html { redirect_to @building, notice: 'Building was successfully updated.' }
        format.json { render :show, status: :ok, location: @building }
      else
        format.html { render :edit }
        format.json { render json: @building.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /buildings/1
  # DELETE /buildings/1.json
  def destroy
    @building.destroy
    respond_to do |format|
      format.html { redirect_to buildings_url, notice: 'Building was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_building
      @building = Building.find(params[:id])
    end

    def set_buildings
      @buildings = Building.search(params[:filter], building_params[:active_only])
      @buildings = @buildings.order(sort_order).paginate(:page => params[:page], :per_page => 50)
    end

    def sort_order
      sort_column = building_params[:sort_by] || "formatted_street_address"
      #sort_column = Building.column_names.include?(params[:sort_by]) ? params[:sort_by] : "formatted_street_address"
      sort_order = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"

      @sort_by = sort_column + ' ' + sort_order
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    # Need to take in additional params here. Can't rename them, or the geocode plugin
    # will not map to them correctly
    def building_params
      params.permit(:sort_by, :filter, :active_only, :street_number, :route, :neighborhood, :sublocality, 
       :administrative_area_level_2_short, :administrative_area_level_1_short, :postal_code,
       :country_short, :lat, :lng, :place_id, :building => [:formatted_street_address, :notes, :landlord_id])
    end
end
