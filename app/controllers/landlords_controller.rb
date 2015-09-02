class LandlordsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => :create
  before_action :set_landlord, except: [:index, :new, :create, :filter, 
    :filter_listings, :autocomplete_landlord_code]
  autocomplete :landlord, :code, full: true
  etag { current_user.id }
    
  # GET /landlords
  # GET /landlords.json
  def index

    respond_to do |format|
      format.html do
        set_landlords
      end
      format.csv do
        set_landlords_csv
        headers['Content-Disposition'] = "attachment; filename=\"landlords-list.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  # GET /filter
  # AJAX call
  def filter
    set_landlords
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

  # GET /landlords/1
  # GET /landlords/1.json
  def show
    fresh_when(@landlord)
  end

  # GET /landlords/new
  def new
    @landlord = Landlord.new
    @landlord.company = current_user.company
  end

  # GET /landlords/1/edit
  def edit
  end

  # POST /landlords
  # POST /landlords.json
  def create
    @landlord = Landlord.new(format_params_before_save)
    @landlord.company = current_user.company
    if @landlord.save
      redirect_to @landlord
    else
      # error
      render 'new'
    end
  end

  # PATCH/PUT /landlords/1
  # PATCH/PUT /landlords/1.json
  def update
    if @landlord.update(format_params_before_save.merge({updated_at: Time.now}))
      flash[:success] = "Landlord updated!"
      redirect_to @landlord
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

  # DELETE /landlords/1
  # DELETE /landlords/1.json
  def destroy
    @landlord.archive
    set_landlords
    respond_to do |format|
      format.html { redirect_to landlords_url, notice: 'Landlord was successfully destroyed.' }
      format.json { head :no_content }
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_landlord
      @landlord = Landlord.find_unarchived(params[:id])
      set_units
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "Sorry, that landlord is not active."
      redirect_to :action => 'index'
    end

    def set_units
      active_only = params[:active_only] == "true"
      @residential_units, @res_images = @landlord.residential_units(active_only)
      @residential_units = @residential_units.page params[:page]
      @commercial_units, @com_images = @landlord.commercial_units(active_only)
      @commercial_units = @commercial_units.page params[:page]
    end

    def set_landlords
      @landlords = Landlord.search(params)
      @landlords = custom_sort
      @landlords = @landlords.page params[:page]
    end

    def set_landlords_csv
      @landlords = Landlord.search_csv(params)
      @landlords = custom_sort
    end

    def custom_sort
      sort_column = params[:sort_by] || "name"
      sort_order = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
      params[:sort_by] = sort_column
      params[:direction] = sort_order
      #puts "***** #{params[:sort_by]} #{params[:direction]}"
      # TODO: fix it so we can sort by all columns
      if Landlord.column_names.include?(params[:sort_by])
        if sort_column == 'name' || sort_column == 'code'
          @landlords = @landlords.order("LOWER(#{sort_column}) " + sort_order)
        else
          @landlords = @landlords.order(sort_column + ' ' + sort_order)
        end
      end
      @landlords
    end

    def format_params_before_save
      # get the whitelisted set of params, then arrange data
      # into the right format for our model
      param_obj = landlord_params
      param_obj[:landlord].each{ |k,v| param_obj[k] = v };
      param_obj.delete("landlord")

      param_obj
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def landlord_params

      params.permit(:sort_by, :filter, :agent_filter, :active_only, :street_number, :route, 
        :neighborhood, :sublocality, :administrative_area_level_2_short, 
        :administrative_area_level_1_short, :postal_code, :country_short, :lat, :lng, :place_id, 
        :landlord => [:code, :name, :contact_name, :mobile, :office_phone, :fax, 
          :email, :website, :formatted_street_address, :notes, 
          :listing_agent_percentage, :listing_agent_id,
          :has_fee, :op_fee_percentage, :tp_fee_percentage, 
          :management_info, :key_pick_up_location, :update_source ])
    end
end
