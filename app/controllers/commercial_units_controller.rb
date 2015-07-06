class CommercialUnitsController < ApplicationController
  load_and_authorize_resource
  before_action :set_commercial_unit, except: [:new, :create, :index, :filter, 
    :neighborhoods_modal, :features_modal, :update_subtype]
  etag { current_user.id }

  # GET /commercial_units
  # GET /commercial_units.json
  def index
    set_commercial_units
    fresh_when(@commercial_units)
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
    fresh_when(@commercial_unit)
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        render pdf: current_user.name + ' Commercial - Private',
          template: "/commercial_units/print_private.pdf.erb",
          layout:   "/layouts/pdf_layout.html"
      end
    end
  end

  # GET /commercial_units/new
  def new
    @commercial_unit = CommercialUnit.new
    if params[:building_id]
      building = Building.find(params[:building_id])
      @commercial_unit.building_id = building.id
    end

    @panel_title = "Add a listing"
    set_property_types
  end

  # GET /commercial_units/1/edit
  def edit
    @panel_title = "Edit listing"
    set_property_types
  end

  def update_subtype
    ptype = params[:property_type]
    @property_sub_types = CommercialPropertyType.subtypes_for(ptype, current_user.company)

    respond_to do |format|
      format.js  
    end
  end

  # POST /commercial_units
  # POST /commercial_units.json
  def create
    @commercial_unit = CommercialUnit.new(commercial_unit_params)
    #@commercial_unit.listing_id = Unit.generate_unique_id
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
    commercial_unit_dup = @commercial_unit.duplicate(
      commercial_unit_params[:building_unit], commercial_unit_params[:include_photos])
    if commercial_unit_dup.valid?
      @commercial_unit = commercial_unit_dup
      render :js => "window.location.pathname = '#{commercial_unit_path(@commercial_unit)}'"
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
  def print_modal
    respond_to do |format|
      format.js  
    end
  end

  #def print_private
    #respond_to do |format|
    #  format.pdf do
        # render pdf: current_user.name + ' Commercial - Private',
        #   template: "/commercial_units/print_private.pdf.erb",
        #   disposition: "attachment",
        #   layout:   "/layouts/pdf_layout.html"
    #  end
    #end
  #end

  # PATCH/PUT /commercial_units/1
  # PATCH/PUT /commercial_units/1.json
  def update
    params[:commercial_unit][:commercial_property_type_id] = params[:commercial_property_type_id]

    if @commercial_unit.update(commercial_unit_params)
      flash[:success] = "Unit successfully updated!"
      redirect_to @commercial_unit
    else
      set_property_types
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

  # DELETE /commercial_units/1
  # DELETE /commercial_units/1.json
  def destroy
    @commercial_unit.archive
    set_commercial_units
    respond_to do |format|
      format.html { redirect_to commercial_units_url, notice: 'Commercial unit was successfully destroyed.' }
      format.json { head :no_content }
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
    @commercial_unit.inaccuracy_description = commercial_unit_params[:inaccuracy_description]
    @commercial_unit.send_inaccuracy_report(current_user)
    respond_to do |format|
      format.js { flash[:notice] = "Report submitted! Thank you." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commercial_unit
      @commercial_unit = CommercialUnit.find_unarchived(params[:id])
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

    def set_property_types
      @property_types = current_user.company.commercial_property_types
      .select(:property_type).order('property_type ASC').distinct

      if @commercial_unit.commercial_property_type
        @property_sub_types = CommercialPropertyType.subtypes_for(
          @commercial_unit.commercial_property_type.property_type, current_user.company)
      end
    end

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
      params[:commercial_unit].permit(:building_unit, :rent, :status, :available_by, 
        :status, :building_id, :user_id, :include_photos,
        :sq_footage, :floor, :building_size, :build_to_suit, :minimum_divisble, :maximum_contiguous,
        :lease_type, :is_sublease, :property_description, :location_description,
        :construction_status, :no_parking_spaces, :pct_procurement_fee, :lease_term_months,
        :rate_is_negotiable, :total_lot_size, :property_type, :commercial_property_type_id,
        :inaccuracy_description)
    end
end
