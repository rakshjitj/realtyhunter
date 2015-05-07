class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy]
  before_action :correct_user,   only: [:show, :edit, :update, :destroy]
  #before_action :compose_pre_post

  # GET /users
  # GET /users.json
  def index
    #@users = User.all
    @users = User.search(params[:search])
    @users = @users.paginate(:page => params[:page], :per_page => 50)
    #@users = User.where(activated: true).paginate(page: params[:page])
    #@users = User.paginate(:page => params[:page], :per_page => 50)
  end

  # GET /users/1
  # GET /users/1.json
  def show
    # TODO: only show if this is an active user
    redirect_to root_url and return unless @user.activated == true
  end

  # GET /users/new
  def new
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: 201, acl: :public_read)
    puts "#{@s3_direct_post.inspect}"
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    #respond_to do |format|
      if @user.save
        #log_in @user
        #flash[:success] = "Welcome " + @user.fname + " " + @user.lname + "!"
        #format.html { redirect_to @user, notice: 'User was successfully created.' }
        #format.json { render :show, status: :created, location: @user }
        @user.send_activation_email
        flash[:info] = "Please check your email to activate your account."
        redirect_to root_url
      else
        #puts "**** #{@user.errors.inspect}"
        #format.html { render :new }
        #format.json { render json: @user.errors, status: :unprocessable_entity }
        render 'new'
      end
    #end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated!"
      redirect_to @user
    else
      puts "**** #{@user.errors.inspect}"
      render 'edit'
    end
#    respond_to do |format|
#      if @user.update(user_params)
#        format.html { redirect_to @user, notice: 'User was successfully updated.' }
#        format.json { render :show, status: :ok, location: @user }
#      else
#        format.html { render :edit }
#        format.json { render json: @user.errors, status: :unprocessable_entity }
#      end
#    end
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

    def compose_pre_post
      #@s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: 201, acl: :public_read)
    end

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      #redirect_back_or users_path unless @user == current_user
      unless @user == current_user
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
      params.require(:user).permit(:email, :fname, :lname, :bio, :password, 
        :password_confirmation, :avatar_url, :phone_number, :mobile_phone_number)
    end
end
