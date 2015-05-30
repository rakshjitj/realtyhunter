class ResidentialUnitsController < ApplicationController
  load_and_authorize_resource
  before_action :set_residential_unit, except: [:new, :create, :index, :filter]

  # GET /residential_units
  # GET /residential_units.json
  def index
    #@residential_units = ResidentialUnit.all.paginate(:page => params[:page], :per_page => 50)
    set_residential_units
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
    set_residential_units
  end

  # GET /residential_units/1
  # GET /residential_units/1.json
  def show
  end

  # GET /residential_units/new
  def new
    @residential_unit = ResidentialUnit.new
  end

  # GET /residential_units/1/edit
  def edit
  end

  # POST /residential_units
  # POST /residential_units.json
  def create
    @residential_unit = ResidentialUnit.new(residential_unit_params)
    @residential_unit.listing_id = ResidentialUnit.generate_unique_id

    if @residential_unit.save
      redirect_to @residential_unit
    else
      render 'new'
    end
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
    @residential_unit.destroy
    set_residential_units
    respond_to do |format|
      format.html { redirect_to residential_units_url, notice: 'Residential unit was successfully destroyed.' }
      format.json { head :no_content }
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_residential_unit
      @residential_unit = ResidentialUnit.find(params[:id])
    end

    def set_residential_units
      @residential_units = ResidentialUnit.search(params[:filter], params[:active_only])
      @residential_units = custom_sort
      @residential_units = @residential_units.paginate(:page => params[:page], :per_page => 50)
    end

    def custom_sort
      sort_column = params[:sort_by] || "rent"
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
      params[:residential_unit].permit(:building_unit, :rent, :available_by, 
        :access_info, :status, :open_house, :weeks_free_offered, 
        :building_id, :user_id, :beds, :baths, :notes, :lease_duration,
        :residential_amenity_ids => [])
    end
end
