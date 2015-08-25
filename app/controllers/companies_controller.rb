class CompaniesController < ApplicationController
  load_and_authorize_resource
  skip_before_action :logged_in_user, only: [:new, :create]
  before_action :set_company, except: [:new, :filter, :create, :index]
  etag { current_user.id }
  
  # GET /companies
  # GET /companies.json
  def index
    set_companies
  end

  def filter
    set_companies
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    @employee_titles = EmployeeTitle.all.map{|e| e.display_name}
    @agent_types = AgentType.all.map{|e| e.display_name}
    fresh_when(@company)
  end

  # GET /companies/new
  def new
    @company = Company.new
    # build 1 user
    @company.users.build
  end

  # GET /companies/1/edit
  def edit
    #@agent_types = AgentType.all_cached.map{|e| e.display_name}
    #@company.agent_types = @agent_types.join("\n")
    #@employee_titles = EmployeeTitle.all_cached.map{|e| e.display_name}
    #@company.employee_titles = @employee_titles.join("\n")
  end

  # GET /team/1
  # GET /teams/1.json
  def managers
    @title = 'Managers'
    @users = @company.managers
    @users = @users.page params[:page]
    @user_images = User.get_images(@users)
    render 'users/index'
  end

  def employees
    @title = 'Employees'
    @users = @company.users.unarchived.includes(
      :office, :employee_title, :image, :company, :manager, :roles).page params[:page]
    @user_images = User.get_images(@users)
    render 'users/index'
  end

  # POST /companies
  # POST /companies.json
  def create
    @saved = false
    log_out if logged_in?
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
      img_params = company_params.dup
      params[:company].delete("file")

      if @company.update(company_params)
        img_params.delete("name")
        @company.image = Image.create(img_params)
        flash[:success] = 'Company was successfully updated.'
        # TODO: make environment editable
        #@company.update_agent_types
        #@company.update_employee_titles
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
    @company.archive
    set_companies
    respond_to do |format|
      flash[:success] = 'Company was successfully destroyed.'
      format.html { redirect_to companies_url }
      format.json { head :no_content }
    end
  end

  def destroy_image
    if @company.image
      @company.image = nil
    end
    respond_to do |format|
      format.js  
    end
  end

  private
    def set_company
      @company = Company.find(params[:id])
    end

    def set_companies
      @companies = Company.search(params[:search_params])
      @companies = @companies.unarchived.page params[:page]
    end

    def company_params
      params.require(:company).permit(:name, :file, :agent_types, :employee_titles,
        users_attributes: [:name, :email, :password, :password_confirmation])
    end
end
