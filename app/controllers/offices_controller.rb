class OfficesController < ApplicationController
  load_and_authorize_resource
  before_action :set_office, except: [:new, :create, :index]

  # GET /offices
  # GET /offices.json
  def index
    @company = Company.find(params[:company_id])
    @offices = Office.where(company: @company)
  end

  # GET /offices/1
  # GET /offices/1.json
  def show
  end

  # GET /offices/new
  def new
    @company = Company.find(params[:company_id])
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
    @company = Company.find(params[:company_id])
    @office = @company.offices.build(office_params)

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
      if @office.update(office_params)
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
    @office.destroy
    flash[:success] = 'Office was successfully destroyed.'
    respond_to do |format|
      format.html { redirect_to company_offices_url(@office)}
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_office
      @company = Company.find(params[:company_id])
      @office = Office.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def office_params
      params.require(:office).permit(:name, :telephone, :street_address, :city, 
        :state, :zipcode, :fax)
    end
end
