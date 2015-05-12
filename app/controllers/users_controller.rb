class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :show, :edit, :upload_image, :destroy]
  before_action :correct_user,   only: [:show, :edit, :update, :upload_image, :destroy]

  # GET /users
  # GET /users.json
  def index
    #@users = User.all
    @users = User.search(params[:search])
    @users = @users.paginate(:page => params[:page], :per_page => 50)
    #@users = User.where(activated: true).paginate(page: params[:page])
    #@users = User.paginate(:page => params[:page], :per_page => 50)
  end

  # GET /coworkers
  # GET /coworkers.json
  def coworkers
    @users = current_user.coworkers
    @users = @users.paginate(:page => params[:page], :per_page => 50)
    render 'index'
  end

  # GET /subordinates
  # GET /subordinates.json
  def subordinates
    @users = current_user.subordinates
    @users = @users.paginate(:page => params[:page], :per_page => 50)
    render 'index'
  end
  # GET /users/1
  # GET /users/1.json
  def show
    # TODO: only show if this is an active user
    redirect_to root_url and return unless @user.activated == true
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    if @user.save
      #flash[:success] = "Welcome " + @user.name + "!"
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      #log_out
      redirect_to root_url
    else
      #puts "**** #{@user.errors.inspect}"
      render 'new'
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated!"
      redirect_to @user
    else
      #puts "**** #{@user.errors.inspect}"
      render 'edit'
    end
  end

  # PATCH /users/1
  def upload_image
    # TODO: 
    # resize image & upload new image to S3
    @user = User.find(params[:id])
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

  private

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      #puts "***ID**** #{params.inspect}"
      #redirect_back_or users_path unless @user == current_user
      unless (@user.has_role?(:admin) || @user == current_user)
        flash[:danger] = "You are not authorized to go there."
        redirect_back_or users_url
        #redirect_to(users_url)
      end
      #redirect_to(root_url) unless @user == current_user
    end

    # Use callbacks to share common setup or constraints between actions.
    #def set_user
    #  @user = User.find(params[:id])
    #end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :name, :mobile_phone_number, :bio, :password, 
        :password_confirmation, :avatar, :remove_avatar, :remote_avatar_url, :phone_number, :mobile_phone_number)
    end
end
