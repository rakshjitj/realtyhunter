class UsersController < ApplicationController
  skip_before_action :logged_in_user, only: [:new, :create]
  before_action :lookup_user, except: [:index, :new, :batch_new, :create]

  # GET /users
  # GET /users.json
  def index
    #@users = User.all
    @users = User.search(params[:search])
    @users = @users.paginate(:page => params[:page], :per_page => 50)
    @title = 'All users'
    #@users = User.where(activated: true).paginate(page: params[:page])
    #@users = User.paginate(:page => params[:page], :per_page => 50)
  end

  # GET /coworkers/1
  # GET /coworkers/1.json
  def coworkers
    @users = @user.coworkers
    @users = @users.paginate(:page => params[:page], :per_page => 50)
    @title = @user.company.name.titleize + ' Employees'
    render 'index'
  end

  # GET /subordinates/1
  # GET /subordinates/1.json
  def subordinates
    @manager = User.find(params[:id])
    @subordinates = @manager.subordinates
    @subordinates = @subordinates.paginate(:page => params[:page], :per_page => 50)
    @title = @manager.fname.titleize + "'s Team"
    render 'subordinates'
  end
  # GET /users/1
  # GET /users/1.json
  def show
    @agent_title = EmployeeTitle.agent
    #puts "***ID**** #{params.inspect}"
    # TODO: only show if this is an active user
    #redirect_to root_url and return unless @user.activated == true
  end

  # GET /users/new
  # GET /signup
  def new
    @company = Company.where(name: 'MyspaceNYC').first
    @agent_title = EmployeeTitle.agent
    @user = User.new
  end

  # GET /users/batch_new
  def batch_new
    @user = User.new
    @roles = Role.where.not(name: 'super_admin')
    render 'admin.new'
  end

  # GET /users/1/edit
  def edit
    @agent_title = EmployeeTitle.agent
  end

  # POST /users
  # POST /users.json
  def create

    @user = User.new(user_params)
    # TODO: extend to other companies
    @user.company = Company.where(name: 'MyspaceNYC').first
    if @user.save
      # add in each role type
      @user.update_roles
      @user.send_activation_email
      @user.send_company_approval_email
      flash[:info] = "Please check your email to activate your account."
      #log_out
      redirect_to root_url
    else
      #puts "**** #{@user.errors.inspect}"
      @agent_title = EmployeeTitle.agent
      render 'new'
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @agent_title = EmployeeTitle.agent
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
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # happens when an admin approves a user account through
  # the webpage instead of through email
  # PATCH /users/1/admin_approve
  def admin_approve
    @user.approve
    redirect_to users_path
  end

  def admin_unapprove
    @user.unapprove
    redirect_to users_path
  end

  private

    # Confirms the correct user.
    def lookup_user
    #def correct_user
      #puts "***ID**** #{params.inspect}"
      #redirect_back_or users_path unless @user == current_user
      @user = User.find(params[:id])

      #unless (@current_user.is_management? || @user == current_user)
      #  flash[:danger] = "You are not authorized to go there."
      #  redirect_back_or users_url
      #  #redirect_to(users_url)
      #end
      ##redirect_to(root_url) unless @user == current_user
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
