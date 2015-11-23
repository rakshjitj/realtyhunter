class UsersController < ApplicationController
  load_and_authorize_resource
  skip_before_action :logged_in_user, only: [:new, :create, :update_offices]
  before_action :set_user, except: [:index, :filter, :filter_listings, :teams, :new, :create, :admin_new,
    :admin_create, :update_offices, :autocomplete_user_name, :unarchive]
  before_action :set_company, except: [:update_offices]
  autocomplete :user, :name, full: true

  # GET /users
  # GET /users.json
  def index
    params[:status] = 'Active'
    #@agent_title = EmployeeTitle.agent
    set_users
    @title = 'All users'
  end

  # AJAX call
  def filter
    set_users
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

  # GET /coworkers/1
  # GET /coworkers/1.json
  def coworkers
    @users = @user.coworkers.order("created_at ASC")
    @users = @users.page params[:page]
    @title = @user.company.name + ' Employees'
    render 'index'
  end

  # GET /subordinates/1
  # GET /subordinates/1.json
  def subordinates
    @manager = User.find(params[:id])
    @users = @manager.subordinates.order("created_at ASC")
    @users = @users.page params[:page]
    @title = @manager.fname.titleize + "'s Team"
    render 'index'
  end
  # GET /users/1
  # GET /users/1.json
  def show
    # TODO: only show if this is an active user
    #fresh_when([@user, @user.image])
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
    @companies = Company.all
    @offices = []
    @employtee_titles = EmployeeTitle.where.not("name like ?", "%admin%")
    @user = User.new
  end

  # GET /users/batch_new
  def admin_new
    @default_role_set = Role.where(name: ['residential', 'commercial', 'sales']).map(&:id)
    @user = User.new
  end

  # POST /users/batch_create
  # POST /users/batch_create
  def admin_create
    @user = User.new(user_params)
    @user.company = current_user.company
    @user.assign_random_password
    if @user.save
      @user.approve
      @user.activate
      # add in each role type
      @user.update_roles
      # send users an email prompting them to change pass & login
      @user.create_reset_digest
      @user.send_added_by_admin_email(current_user.company)
      flash[:success] = "Users have been notified!"
      redirect_to admin_new_users_path
    else
      render 'admin_new'
    end
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    log_out if logged_in?
    if @user.save
      # add in each role type
      @user.update_roles
      @user.send_activation_email
      @user.send_company_approval_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      #puts "**** #{@user.errors.inspect}"
      @companies = Company.all
      @offices = []
      @employtee_titles = EmployeeTitle.where.not("name like ?", "%admin%")
      @agent_title = EmployeeTitle.agent
      render 'new'
    end
  end



  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if @user.update(user_params.merge({updated_at: Time.now}))
      @user.update_roles
      flash[:success] = "Profile updated!"
      redirect_to @user
    else
      #puts "**** #{@user.errors.inspect}"
      render 'edit'
    end
  end

  # POST /users/1
  def upload_image
    image = Image.create(user_params)
    if image
      # delete old image
      # TODO verify this removes old image from S3!
      @user.image = nil
      # add new image
      @user.image = image
      flash[:success] = "Profile image updated!"
      redirect_to @user
    else
      #puts "**** #{@user.errors.inspect}"
      render 'edit'
    end
  end

  def destroy_image
    if @user.image
      @user.image = nil
    end
    respond_to do |format|
      format.js
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.archive
    set_users
    # if this is us, log us out
    if (current_user == @user)
      log_out if logged_in?
    else
      respond_to do |format|
        format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
        format.json { head :no_content }
        format.js
      end
    end
  end

  # effectively un-delete, the opposite of destroy() above.
  def unarchive
    @user.update_attribute(:archived, false)
    params[:status] = 'Deleted'
    set_users
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully un-deleted.' }
      format.json { head :no_content }
      format.js
    end
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

  # PATCH
  def new_auth_token
    @user.auth_token = nil
    @user.set_auth_token
    @user
    respond_to do |format|
      format.js
    end
  end

  protected

    def correct_stale_record_version
      @user.reload
      params[:user].delete('lock_version')
    end

  private
    def set_company
      @agent_title = EmployeeTitle.agent
    end

    # Confirms the correct user.
    def set_user
      @user = User.find_unarchived(params[:id])
      #@agent_title = EmployeeTitle.agent
      set_units
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "Sorry, that user account is not active."
      redirect_to :action => 'index'
    end

    def set_users
      @users = User.search(params, current_user)
      @users = @users.page params[:page]
      @user_images = User.get_images(@users)
    end

    def set_units
      active_only = params[:active_only] == "true"
      @residential_units, @res_images = @user.residential_units(active_only)
      @residential_units = @residential_units.page params[:page]
      @commercial_units, @com_images = @user.commercial_units(active_only)
      @commercial_units = @commercial_units.page params[:page]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:lock_version, :email, :name, :mobile_phone_number,
        :bio, :password, :password_confirmation, :avatar, :remove_avatar,
        :remote_avatar_url, :phone_number, :status, :mobile_phone_number,
        :employee_title_id, :company_id, :office_id, :file,
        role_ids: [],
        agent_types: [])
    end
end
