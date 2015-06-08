class UsersController < ApplicationController
  load_and_authorize_resource
  skip_before_action :logged_in_user, only: [:new, :create, :update_offices]
  before_action :set_user, except: [:index, :teams, :new, :batch_new, :create, :batch_create, :batch_add_user, :update_offices]
  before_action :set_company, except: [:update_offices]

  # GET /users
  # GET /users.json
  def index
    @agent_title = EmployeeTitle.agent
    set_users
    @title = 'All users'
  end

  # GET /coworkers/1
  # GET /coworkers/1.json
  def coworkers
    @users = @user.coworkers
    @users = @users.paginate(:page => params[:page], :per_page => 50).order("created_at ASC")
    @title = @user.company.name + ' Employees'
    render 'index'
  end

  # GET /subordinates/1
  # GET /subordinates/1.json
  def subordinates
    @manager = User.find(params[:id])
    @users = @manager.subordinates
    @users = @users.paginate(:page => params[:page], :per_page => 50).order("created_at ASC")
    @title = @manager.fname.titleize + "'s Team"
    render 'index'
  end
  # GET /users/1
  # GET /users/1.json
  def show
    # TODO: only show if this is an active user
    #redirect_to root_url and return unless @user.activated == true
  end

  # GET /update_offices
  # AJAX call - updates drop down on user signup page
  def update_offices
    @offices = Office.where("company_id = ?", params[:company_id])
    @offices = @offices.map{|o| [o.name, o.id]}.insert(0, "Select an office")
  end

  # GET /users/new
  # GET /signup
  def new
    #@company = Company.find_by(name: "MyspaceNYC")
    @companies = Company.all
    @offices = []
    @employtee_titles = EmployeeTitle.where.not("name like ?", "%admin%")
    @agent_title = EmployeeTitle.agent
    @user = User.new
  end

  # GET /users/batch_new
  def batch_new
    @agent_title = EmployeeTitle.agent
    @users = []
    @users << User.new
  end

  def batch_add_user
    @builder = User.new
    respond_to do |format|
      format.js #batch_add_user.js.erb
    end
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.auth_token = User.set_auth_token
    log_out if logged_in?
    if @user.save
      # add in each role type
      @user.update_roles
      @user.send_activation_email
      @user.send_company_approval_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      puts "**** #{@user.errors.inspect}"
      @companies = Company.all
      @offices = []
      @employtee_titles = EmployeeTitle.where.not("name like ?", "%admin%")
      @agent_title = EmployeeTitle.agent
      render 'new'
    end
  end

  # POST /users/batch_create
  # POST /users/batch_create
  def batch_create
    #@user = User.new(user_params)
    # @user.company = @company
    # @user.assign_random_password
    # if @user.save
    #   @user.approve
    #   # add in each role type
    #   @user.update_roles
    #   # send users an email prompting them to change pass & login
    #   @user.create_reset_digest
    #   @user.send_added_by_admin_email(current_user.company)
    #   flash[:info] = "Users have been notified"
    #   redirect_to root_url
    # else
    #   render 'batch_new'
    # end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    #@user = User.find(params[:id])
    if @user.update_attributes(user_params)
      @user.update_roles
      flash[:success] = "Profile updated!"
      redirect_to @user
    else
      #puts "**** #{@user.errors.inspect}"
      render 'edit'
    end
  end

  # PATCH /users/1
  def upload_image
    # TODO: lock down params
    #@user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile image updated!"
      redirect_to @user
    else
      #puts "**** #{@user.errors.inspect}"
      render 'edit'
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    #@user.destroy
    @user.archive
    set_user
    set_users
    # if this is us, log us out
    if (current_user == @user)
      log_out if logged_in?
    else
      respond_to do |format|
        format.js  
      end
    end
    
    #respond_to do |format|
    #  format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
    #  format.json { head :no_content }
    #  format.js
    #end
  end

  # happens when an admin approves a user account through
  # the webpage instead of through email
  # POST /users/1/admin_approve
  def admin_approve
    if current_user.can_approve(@user)
      @user.approve
    else
      flash[:danger] = "You are not authorized to do that."
    end
    set_user
    set_users
    respond_to do |format|
      format.js
    end
  end

  # POST
  def admin_unapprove
    if current_user.can_approve(@user)
      @user.unapprove
    else
      flash[:danger] = "You are not authorized to do that."
    end
    set_user
    set_users
    respond_to do |format|
      format.js
    end
  end

  # POST
  def admin_kick
    if current_user.can_kick(@user)
      @user.kick
    else
      flash[:danger] = "You are not authorized to do that."
    end
    set_user
    set_users
    respond_to do |format|
      format.js
    end
  end

  private
    def set_company
      @agent_title = EmployeeTitle.agent
    end

    # Confirms the correct user.
    def set_user
    #def correct_user
      #puts "***ID**** #{params.inspect}"
      #redirect_back_or users_path unless @user == current_user
      @user = User.find_unarchived(params[:id])
      @agent_title = EmployeeTitle.agent
      #unless (@current_user.is_management? || @user == current_user)
      #  flash[:danger] = "You are not authorized to go there."
      #  redirect_back_or users_url
      #  #redirect_to(users_url)
      #end
      ##redirect_to(root_url) unless @user == current_user
    end

    def set_users
      #@users = User.where(activated: true).paginate(page: params[:page])
      @users = User.search(params[:search])
      @users = @users.paginate(:page => params[:page], :per_page => 50).order("created_at ASC")
    end

    # Use callbacks to share common setup or constraints between actions.
    #def set_user
    #  @user = User.find(params[:id])
    #end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :name, :mobile_phone_number, :bio, :password, 
        :password_confirmation, :avatar, :remove_avatar, :remote_avatar_url, :phone_number, 
        :mobile_phone_number, :employee_title_id, :company_id, :office_id, agent_types: [])
    end
end
