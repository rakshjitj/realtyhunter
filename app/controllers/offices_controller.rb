class OfficesController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => :create
  before_action :set_company, except: [:destroy]
  before_action :set_office, except: [:new, :create, :index]

  # GET /offices
  # GET /offices.json
  def index
    set_offices
  end

  # GET /offices/1
  # GET /offices/1.json
  def show
  end

  # GET /offices/new
  def new
    @office = @company.offices.build
  end

  # GET /offices/1/edit
  def edit
  end

  def managers
    @users = @office.managers
  end

  def agents
    @users = @office.agents
    @users.sort_by!{|u| u.name.downcase }
    @users = @users.paginate(:page => params[:page], :per_page => 50)
    render 'users/index'    
  end

  # POST /offices
  # POST /offices.json
  def create
    @office = @company.offices.build(format_params_before_save)

    respond_to do |format|
      if @office.save
        flash[:success] = 'Office was successfully created.' 
        format.html { redirect_to company_office_path(@company, @office)}
        format.json { render :show, status: :created, location: @office }
      else
        format.html { render :new }
        format.json { render json: @office.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /offices/1
  # PATCH/PUT /offices/1.json
  def update
    respond_to do |format|
      if @office.update(format_params_before_save)
        flash[:success] = 'Office was successfully updated.'
        format.html { redirect_to company_office_path(@company, @office) }
        format.json { render :show, status: :ok, location: @office }
      else
        format.html { render :edit }
        format.json { render json: @office.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /offices/1
  # DELETE /offices/1.json
  def destroy
    @company = @office.company
    @office.archive
    set_offices
    flash[:success] = 'Office was successfully destroyed.'
    respond_to do |format|
      format.html { redirect_to company_offices_url(@office)}
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_office
      @office = Office.find_unarchived(params[:id])
    end

    def set_offices
      @offices = Office.unarchived.includes(:company).where(company: @company)
    end

    def set_company
      @company = Company.find_unarchived(params[:company_id])
    end

    def format_params_before_save
      # get the whitelisted set of params, then arrange data
      # into the right format for our model
      param_obj = office_params
      param_obj[:office].each{ |k,v| param_obj[k] = v };
      param_obj.delete("office")
      
      param_obj
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def office_params
      params.permit(:direction, :filter, :street_number, :route, 
        :sublocality, :administrative_area_level_2_short, :administrative_area_level_1_short, 
        :postal_code, :country_short, :lat, :lng, :place_id,
        :office => [:formatted_street_address, :name, :telephone, :street_address, :city, 
        :state, :zipcode, :fax ])
    end
end
