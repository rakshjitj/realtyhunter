class CompaniesController < ApplicationController
  load_and_authorize_resource
  skip_before_action :logged_in_user, only: [:new, :create]
  before_action :set_company, except: [:new, :create, :index]

  # GET /companies
  # GET /companies.json
  def index
    @companies = Company.all
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    @employee_titles = EmployeeTitle.all.map{|e| e.display_name}
    @agent_types = AgentType.all.map{|e| e.display_name}
  end

  # GET /companies/new
  def new
    @company = Company.new
    # build 1 user
    @company.users.build
  end

  # GET /companies/1/edit
  def edit
    @agent_types = AgentType.all.map{|e| e.display_name}
    @company.agent_types = @agent_types.join("\n")
    @employee_titles = EmployeeTitle.all.map{|e| e.display_name}
    @company.employee_titles = @employee_titles.join("\n")
  end

  # GET /team/1
  # GET /teams/1.json
  def managers
    @users = @company.managers
    @users.sort_by!{|u| u.name.downcase }
    @users = @users.paginate(:page => params[:page], :per_page => 50)
    render 'users/index'
  end

  def employees
    @users = @company.users.paginate(:page => params[:page], :per_page => 50)
    render 'users/index'
  end

  # POST /companies
  # POST /companies.json
  def create
    @saved = false
    Company.transaction do
      @company = Company.new(company_params)
      @company.save
      @company_admin = @company.users[0]
      @company_admin.make_company_admin
      @company_admin.send_activation_email
      @company_admin.approve
      @company_admin.save
      @saved = true
    end

    if @saved
      flash[:success] = 'Company was successfully created. Please check your email to activate your account.'
      redirect_to root_url
    else
      #puts "**** #{@user.errors.inspect}"
      render 'new'
    end

  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        flash[:success] = 'Company was successfully updated.'
        # TODO: tie these values to a company
        @company.update_agent_types
        @company.update_employee_titles
        format.html { redirect_to @company }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company.destroy
    respond_to do |format|
      flash[:success] = 'Company was successfully destroyed.'
      format.html { redirect_to companies_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:name, :logo, :remove_logo, :remote_logo_url,
        :agent_types, :employee_titles,
        users_attributes: [:name, :email, :password, :password_confirmation])
    end
end
