class UnitsController < ApplicationController
  before_action :set_unit, only: [:show, :edit, :update, :destroy]
  add_flash_types :error, :another_custom_type
  # GET /units
  # GET /units.json
  def index
    @units = Unit.unarchived
  end

  # GET /units/1
  # GET /units/1.json
  def show
  end

  # GET /units/new
  def new
    @unit = Unit.new
  end

  # GET /units/1/edit
  def edit
  end

  # POST /units
  # POST /units.json
  def create
    @unit = Unit.new(unit_params)
    @unit.listing_id = rand(max)
    respond_to do |format|
      if @unit.save
        format.html { redirect_to @unit, notice: 'Unit was successfully created.' }
        format.json { render :show, status: :created, location: @unit }
      else
        format.html { render :new }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @unit.update(unit_params)
        format.html { redirect_to unit_path(@unit), notice: 'Unit was successfully updated.' }
        format.json { render :show, status: :ok, location: @unit }
      else
        format.html { render :edit }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @unit.archive
    @units = Unit.unarchived
    respond_to do |format|
      format.html { redirect_to units_url, notice: 'Unit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_open_hours
    #abort params[:day].inspect
    if params[:from_day]
      from_change_date = params[:from_day].split("/")
      from_day_change = from_change_date[1] + "/" + from_change_date[0] + "/" + from_change_date[2]
      final_from_day = Date.parse(from_day_change)
      till_change_date = params[:till_day].split("/")
      till_day_change = till_change_date[1] + "/" + till_change_date[0] + "/" + till_change_date[2]
      final_till_day = Date.parse(till_day_change)
      total_days = (final_till_day - final_from_day).to_i
    end

    if params[:from_start_time]
      start_hour = params[:from_start_time].to_a[0][1]
      start_minute = params[:from_start_time].to_a[1][1]
      total_start_time = start_hour + ":" + start_minute + ":" + "00"
    end
    
    # if params[:from_end_time]
    #   end_hour = params[:from_end_time].to_a[0][1]
    #   end_minute = params[:from_end_time].to_a[1][1]
    #   total_end_time = end_hour + ":" + end_minute + ":" + "00"
    # end

    if params[:till_end_time]
      end_hour = params[:till_end_time].to_a[0][1]
      end_minute = params[:till_end_time].to_a[1][1]
      total_end_time = end_hour + ":" + end_minute + ":" + "00"
    end

    if !params[:landlord].blank?
      #collect_unit = []
      landlord = Landlord.where("code LIKE ?", "%#{params[:landlord]}%")
      @landlord = landlord
        landlord.each do |land|
          land.buildings.each do |build|
            unit = build.units.where(status: [0,1])
            if !unit.blank?
              #@unit = unit
              unit.each do |in_unit|
                if params[:from_day]

                  a = Date::strptime(params[:from_day], "%m/%d/%Y")
                  total_days = total_days + 1
                  total_days.times do |r|
                    b = a + r.days
                    if params[:live_button] != "search"
                      OpenHouse.create(day: b, unit_id: in_unit.id, start_time: total_start_time, end_time: total_end_time)
                    end
                  end
                end

                #temp = OpenHouse.create(day: a, unit_id: in_unit.id, start_time: total_start_time, end_time: total_end_time)
                #abort temp.inspect
                #abort in_unit.inspect
              end
              if params[:live_button] != "search"
                flash[:success] = "Open Houses Hours successfully Added"
              end
            else
              #flash[:errors] = "Record Not Found Please Try with Another Landlord Code.."
            end
          end
        end
        #abort collect_unit.inspect
    end
    
    if !params[:address].blank?
      building = Building.where("formatted_street_address LIKE ?", "%#{params[:address]}%")
      @buildings = building
      building.each do |build|
        unit = build.units.where(status: [0,1])
        if !unit.blank?
          unit.each do |in_unit|
            if params[:from_day]

              a = Date::strptime(params[:from_day], "%m/%d/%Y")
              total_days = total_days + 1
              total_days.times do |r|
                b = a + r.days
                if params[:live_button] != "search"
                  OpenHouse.create(day: b, unit_id: in_unit.id, start_time: total_start_time, end_time: total_end_time)
                end
              end
            end
          end
          if params[:live_button] != "search"
            flash[:success] = "Open Houses Hours successfully Added"
          end
        else
          #flash[:errors] = "Record Not Found Please Try with Another Landlord Code.."
        end
      end
    end

    if !params[:streeteasy_filter].blank?
      if params[:streeteasy_filter] != "Any"
        residential_units = ResidentialListing.search(params, current_user, params[:building_id])
        @residential_units = residential_units
        residential_units.each do |res_unit|
          if params[:from_day]
            a = Date::strptime(params[:from_day], "%m/%d/%Y")
            total_days = total_days + 1
            total_days.times do |r|
              b = a + r.days
              if params[:live_button] != "search"
                OpenHouse.create(day: b, unit_id: res_unit.unit.id, start_time: total_start_time, end_time: total_end_time)
              end
            end
            if params[:live_button] != "search"
              flash[:success] = "Open Houses Hours successfully Added"
            end
          end
        end
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_unit
      @unit = Unit.find_unarchived(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def unit_params
      params.require(:unit).permit(:building_unit, :rent, :available_by,
        :access_info, :status, :open_house, :building_id, :user_id)
    end
end
