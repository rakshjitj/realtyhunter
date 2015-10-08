class RoommatesController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => :create
  before_action :set_roommate, except: [:index, :new, :create, :filter, :download, :send_update]
  autocomplete :roommate, :name, full: true

  def index
    params[:status] = 'Active'
    respond_to do |format|
      format.html do
        set_roommates
      end
    end
  end

  def filter
    set_roommates
    respond_to do |format|
      format.js  
    end
  end

  # GET /residential_units/new
  def new
    @roommate = Roommate.new
  end

  # POST /residential_units
  # POST /residential_units.json
  def create
    @roommate = Roommate.new(roommate_params[:roommate])
    @roommate.user = current_user
    @roommate.company = current_user.company
    if @roommate.save
      flash[:success] = "Roomsharing referral data saved!"
      redirect_to @roommate
    else
      # error
      render 'new'
    end
  end

  def download
  	ids = params[:roommate_ids].split(',')
  	@roommates = Roommate.pull_data_for_export(ids)
    
  	respond_to do |format|
      format.csv do
        #set_roommates_csv
        headers['Content-Disposition'] = "attachment; filename=\"roommates-list.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
      format.pdf do
      	render pdf: current_user.company.name + ' - Roommates - ' + Date.today.strftime("%b%d%Y"),
          template: "/roommates/roommates.pdf.erb",
          orientation: 'Landscape',
          layout:   "/layouts/pdf_layout.html"
      end
    end
  end

  def send_message
    recipients = params[:roommate][:recipients].split(/\s, \,/)
    sub = roommate_params[:title]
    msg = roommate_params[:message]
    Roommate.send_message(current_user, recipients, sub, msg)
    
    respond_to do |format|
      format.js { flash[:success] = "Message sent!"  }
    end
  end

  def show
    @roommate = Roommate.find_unarchived(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "Sorry, that roommate is no longer available."
      redirect_to :action => 'index'
  end

  def edit
    @roommate = Roommate.find_unarchived(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "Sorry, that roommate is no longer available."
      redirect_to :action => 'index'
  end

  def delete_modal
    respond_to do |format|
      format.js  
    end
  end

  # DELETE /residential_units/1
  # DELETE /residential_units/1.json
  def destroy
    @roommate.archive
    set_roommates
    respond_to do |format|
      format.html { redirect_to roommates_url, notice: 'Roommate was successfully inactivated.' }
      format.json { head :no_content }
      format.js
    end
  end

  def unarchive_modal
    respond_to do |format|
      format.js  
    end
  end

  def unarchive
    @roommate.unarchive
    set_roommates
    respond_to do |format|
      format.html { redirect_to roommates_url, notice: 'Roommate was successfully activated.' }
      format.json { head :no_content }
      format.js
    end
  end

  def update
    if @roommate.update(roommate_params[:roommate].merge({updated_at: Time.now}))
      flash[:success] = "Profile updated!"
      redirect_to @roommate
    else
      render 'edit'
    end
  end

  # POST /users/1
  def upload_image
    image = Image.create(roommate_params[:roommate])
    if image
      # delete old image
      # TODO verify this removes old image from S3!
      @roommate.image = nil
      # add new image
      @roommate.image = image
      flash[:success] = "Profile image updated!"
      redirect_to @roommate
    else
      #puts "**** #{@roommate.errors.inspect}"
      render 'edit'
    end
  end

  def destroy_image
    if @roommate.image
      @roommate.image = nil
    end
    respond_to do |format|
      format.js  
    end
  end

  private
  	def set_roommate
      @roommate = Roommate.find_unarchived(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "Sorry, that roommate is not active."
      redirect_to :action => 'index'
  	end

  	def set_roommates
      @neighborhoods = Neighborhood.where(name: [
        'Bedford Stuyvesant',
        'Bushwick',
        'Crown Heights',
        'Greenpoint',
        'Prospect Lefferts Gardens',
        'Prospect Heights',
        'Ridgewood',
        'Williamsburg',
        'Flatbush Ditmas Park'])
      @referrers = current_user.company.users.unarchived.map(&:name).to_a
      @referrers.insert(0, 'Website')

      # if we are logged in as an agent, only let me view my own referrals
      # if cannot? :manage, @roommate
      #   params[:referred_by] = current_user.id
      # end

      @roommates = Roommate.search(params)
      @roommates = custom_sort
      @roommates = @roommates.page params[:page]
      @roommate_images = User.get_images(@roommates)
  	end

  	def custom_sort
      sort_column = params[:sort_by] || "submitted_date"
      sort_order = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
      params[:sort_by] = sort_column
      params[:direction] = sort_order
      #puts "***** #{params[:sort_by]} #{params[:direction]}"
      @roommates = @roommates.order(sort_column + ' ' + sort_order)
      @roommates
  	end

  	def set_roommates_csv
      # @roommates = Roommate.search_csv(params)
      # @roommates = custom_sort
    end

    def roommate_params
    	data = params.permit(:sort_by, :filter, :name, :referred_by, :neighborhood_id,
        :submitted_date, :move_in_date, :monthly_budget, :status,
        :dogs_allowed, :cats_allowed,
        roommate: [:name, :phone_number, 
          :email, :how_did_you_hear_about_us, :upload_picture_of_yourself, :describe_yourself,
          :monthly_budget, :move_in_date, :neighborhood, :dogs_allowed, :cats_allowed,
          :user_id,
          :avatar, :remove_avatar, :remote_avatar_url, :file])

      if data[:roommate]
        if !data[:roommate][:cats_allowed].blank?
          if data[:roommate][:cats_allowed] == "Yes"
            data[:roommate][:cats_allowed] = true
          else
            data[:roommate][:cats_allowed] = false
          end
        end

        if !data[:roommate][:dogs_allowed].blank?
          if data[:roommate][:dogs_allowed] == "Yes"
            data[:roommate][:dogs_allowed] = true
          else
            data[:roommate][:dogs_allowed] = false
          end
        end

        # convert into a datetime obj
        if !data[:roommate][:move_in_date].blank?
          data[:roommate][:move_in_date] = Date::strptime(data[:roommate][:move_in_date], "%m/%d/%Y")
        end

        if !data[:roommate][:neighborhood].blank? && data[:roommate][:neighborhood] != 'Other'
          data[:roommate][:neighborhood] = Neighborhood.find_by(name: data[:roommate][:neighborhood])
        end

        data[:roommate].delete_if{|k,v| (!v || v.blank?) }
      end

      data
    end

  end