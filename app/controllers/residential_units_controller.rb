class ResidentialUnitsController < ApplicationController
  load_and_authorize_resource
  before_action :set_residential_unit, except: [:new, :create, :index]

  # GET /residential_units
  # GET /residential_units.json
  def index
    @residential_units = ResidentialUnit.all.paginate(:page => params[:page], :per_page => 50)
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

    # respond_to do |format|
    #   if @residential_unit.save
    #     format.html { redirect_to @residential_unit, notice: 'Residential unit was successfully created.' }
    #     format.json { render :show, status: :created, location: @residential_unit }
    #   else
        format.html { render :new }
        format.json { render json: @residential_unit.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /residential_units/1
  # PATCH/PUT /residential_units/1.json
  def update
    respond_to do |format|
      if @residential_unit.update(residential_unit_params)
        format.html { redirect_to @residential_unit, notice: 'Residential unit was successfully updated.' }
        format.json { render :show, status: :ok, location: @residential_unit }
      else
        format.html { render :edit }
        format.json { render json: @residential_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /residential_units/1
  # DELETE /residential_units/1.json
  def destroy
    @residential_unit.destroy
    respond_to do |format|
      format.html { redirect_to residential_units_url, notice: 'Residential unit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_residential_unit
      @residential_unit = ResidentialUnit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def residential_unit_params
      params[:residential_unit].permit(:building_unit, :rent, :available_by, 
        :access_info, :status, :open_house, :weeks_free_offered, 
        :building_id, :user_id, :beds, :baths, :notes, :lease_duration,
        :residential_amenity_ids => [])
    end
end
