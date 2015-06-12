class LandlordsController < ApplicationController
  load_and_authorize_resource
  before_action :set_landlord, except: [:index, :new, :create, :filter]

  # GET /landlords
  # GET /landlords.json
  def index
    set_landlords

    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"landlords-list.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  # GET /filter
  # AJAX call
  def filter
    set_landlords
  end

  # GET /landlords/1
  # GET /landlords/1.json
  def show
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
    @landlord = Landlord.new(landlord_params)
    format_params_before_save
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
    if @landlord.update(format_params_before_save)
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
    end

    def set_landlords
      @landlords = Landlord.includes(:buildings).search(params[:filter], params[:agent_filter], params[:active_only])
      @landlords = custom_sort
      @landlords = @landlords.paginate(:page => params[:page], :per_page => 50)
    end

    def custom_sort
      sort_column = params[:sort_by] || "code"
      sort_order = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
      # if sorting by an actual db column, use order
      if Landlord.column_names.include?(params[:sort_by])
        @landlords = @landlords.order(sort_column + ' ' + sort_order)
      # otherwise call sort_by with our custom method
      else
        if sort_order == "asc"
          @landlords = @landlords.sort_by{|b| b.send(sort_column)}
        else
          @landlords = @landlords.sort_by{|b| b.send(sort_column)}.reverse
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

      @landlord.company = current_user.company
      
      param_obj
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def landlord_params
      params.permit(:sort_by, :filter, :agent_filter, :active_only, :street_number, :route, 
        :neighborhood, :sublocality, :administrative_area_level_2_short, 
        :administrative_area_level_1_short, :postal_code, :country_short, :lat, :lng, :place_id, 
        :landlord => [:code, :name, :mobile, :office_phone, :fax, 
          :email, :website, :formatted_street_address, :notes, 
          :listing_agent_percentage, :required_security_id, 
          :management_info])
    end
end
