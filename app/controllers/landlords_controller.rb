class LandlordsController < ApplicationController
  load_and_authorize_resource
  before_action :set_landlord, except: [:index, :new, :create, :filter]

  # GET /landlords
  # GET /landlords.json
  def index
    set_landlords
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
    @landlord.company = current_user.company
    respond_to do |format|
      if @landlord.save
        format.html { redirect_to @landlord, notice: 'Landlord was successfully created.' }
        format.json { render :show, status: :created, location: @landlord }
      else
        format.html { render :new }
        format.json { render json: @landlord.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /landlords/1
  # PATCH/PUT /landlords/1.json
  def update
    respond_to do |format|
      if @landlord.update(landlord_params)
        format.html { redirect_to @landlord, notice: 'Landlord was successfully updated.' }
        format.json { render :show, status: :ok, location: @landlord }
      else
        format.html { render :edit }
        format.json { render json: @landlord.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /landlords/1
  # DELETE /landlords/1.json
  def destroy
    @landlord.destroy
    respond_to do |format|
      format.html { redirect_to landlords_url, notice: 'Landlord was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_landlord
      @landlord = Landlord.find(params[:id])
    end

    def set_landlords
      @landlords = Landlord.search(params[:filter], params[:agent_filter], params[:active_only])
      #names = @landlords.map{|l| l.name}
      @landlords = @landlords.paginate(:page => params[:page], :per_page => 50).order("updated_at ASC")
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def landlord_params
      params.require(:landlord).permit(:code, :name, :phone, :mobile, :fax, 
        :email, :website, :street_address, :city, :state, :zipcode, :notes, 
        :listing_agent_percentage, :required_security_id, :pet_policy, 
        :management_info)
    end
end
