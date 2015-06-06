class CommercialUnitsController < ApplicationController
  load_and_authorize_resource
  before_action :set_commercial_unit, except: [:new, :create, :index, :filter, 
    :neighborhoods_modal, :features_modal]


  # GET /commercial_units
  # GET /commercial_units.json
  def index
    set_commercial_units
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
    set_commercial_units
  end

  # GET /commercial_units/1
  # GET /commercial_units/1.json
  def show
  end

  # GET /commercial_units/new
  def new
    @commercial_unit = CommercialUnit.new
    if params[:building_id]
      building = Building.find(params[:building_id])
      @commercial_unit.building_id = building.id
    end

    @panel_title = "Add a listing"
  end

  # GET /commercial_units/1/edit
  def edit
    @panel_title = "Edit listing"
  end

  # POST /commercial_units
  # POST /commercial_units.json
  def create
    @commercial_unit = CommercialUnit.new(commercial_unit_params)
    @commercial_unit.listing_id = Unit.generate_unique_id
    if !@commercial_unit.available_by?
      @commercial_unit.available_by = Date.today
    end

    if @commercial_unit.save
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
    commercial_unit_dup = @residential_unit.duplicate(
      commercial_unit_params[:building_unit], commercial_unit_params[:include_photos])
    if commercial_unit_dup.valid?
      @residential_unit = commercial_unit_dup
      render :js => "window.location.pathname = '#{commercial_unit_path(@commercial_unit)}'"
    else
      # TODO: not sure how to handle this best...
      flash[:warning] = "Duplication failed!"
      respond_to do |format|
        format.js  
      end
    end
  end

  # PATCH/PUT /commercial_units/1
  # PATCH/PUT /commercial_units/1.json
  def update
    if @commercial_unit.update(commercial_unit_params)
      flash[:success] = "Unit successfully updated!"
      redirect_to @commercial_unit
    else
      render 'edit'
    end
  end

  # DELETE /commercial_units/1
  # DELETE /commercial_units/1.json
  def destroy
    @commercial_unit.destroy
    set_commercial_units
    respond_to do |format|
      format.html { redirect_to commercial_units_url, notice: 'Commercial unit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commercial_unit
      @commercial_unit = CommercialUnit.find(params[:id])
    end

    def set_commercial_units
      search_params = params[:search_params]
      @commercial_units = CommercialUnit.search(search_params, params[:building_id])
      #@commercial_units = CommercialUnit.all
      
      @commercial_units = custom_sort
      @commercial_units = @commercial_units.paginate(:page => params[:page], :per_page => 50)
      #@map_infos = CommercialUnit.set_location_data(@commercial_units)
    end

    # def commercial_units_no_pagination
    #   search_params = params[:search_params]
    #   @commercial_units = CommercialUnit.search(search_params, params[:building_id])
      
    #   @commercial_units = custom_sort
    #   @commercial_units = @commercial_units.paginate(:page => params[:page], :per_page => 50)
    #   @map_infos = CommercialUnit.set_location_data(@commercial_units)
    # end

    def custom_sort
      sort_column = params[:sort_by] || "updated_at"
      sort_order = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
      # if sorting by an actual db column, use order
      if CommercialUnit.column_names.include?(params[:sort_by])
        @commercial_units = @commercial_units.order(sort_column + ' ' + sort_order)
      # otherwise call sort_by with our custom method
      else
        if sort_order == "asc"
          @commercial_units = @commercial_units.sort_by{|b| b.send(sort_column)}
        else
          @commercial_units = @commercial_units.sort_by{|b| b.send(sort_column)}.reverse
        end
      end
      @commercial_units
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def commercial_unit_params
      params[:commercial_unit].permit(:building_unit, :rent, :status, :construction_status, 
        :available_by, :access_info, :status, :open_house, :weeks_free_offered, 
        :building_id, :user_id, :sq_footage, :floor, :property_sub_type, 
        :building_size, :description, :inaccuracy_description)
    end
end
