class OfficesController < ApplicationController
  before_action :logged_in_user, only: [:index, :show, :edit, :destroy]
  before_action :set_office, only: [:show, :edit, :update, :destroy]

  # GET /offices
  # GET /offices.json
  def index
    @offices = Office.all
  end

  # GET /offices/1
  # GET /offices/1.json
  def show
  end

  # GET /offices/new
  def new
    @company = Company.find(params[:company_id])
    @office = @company.offices.build
    #respond_with(@office)
  end

  # GET /offices/1/edit
  def edit
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
