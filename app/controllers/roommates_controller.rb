class RoommatesController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => :create
  before_action :set_roommate, except: [:index, :new, :create, :filter]
  autocomplete :roommate, :name, full: true

  def index
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

  def download
  	ids = params[:roommate_ids].split(',')
  	@roommates = Roommate.where(id: ids)
  	
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

  # handles ajax call. uses latest data in modal
  def neighborhoods_modal
    @neighborhoods = Neighborhood.unarchived
    .where(city: current_user.office.administrative_area_level_2_short)
    .to_a
    .group_by(&:borough)
    
    respond_to do |format|
      format.js  
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
      format.html { redirect_to roommates_url, notice: 'Roommate was successfully deleted.' }
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
  	end

  	def set_roommates
  		do_search
      #@roommates = custom_sort
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

      @roommates = @roommates.page params[:page]
      @roommate_images = User.get_images(@roommates)
  	end

  	def custom_sort
  	end

  	def do_search
  		# @selected_neighborhoods = []
    #   if params[:neighborhood_ids]
    #     neighborhood_ids = params[:neighborhood_ids].split(",").select{|i| !i.empty?}
    #     @selected_neighborhoods = Neighborhood.where(id: neighborhood_ids)
    #   end

      @roommates = Roommate.search(params)
      @roommate_images = []
  	end

  	def set_roommates_csv
      #@landlords = Landlord.search_csv(params)
      #@landlords = custom_sort
    end

    def roommate_params
    	data = params.permit(:sort_by, :filter, :name, :referred_by, :neighborhood_id,
        :submitted_date, :move_in_date, :monthly_budget, 
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
      end

      # params.permit(:sort_by, :filter, :agent_filter, :active_only, :street_number, :route, 
      #   :neighborhood, :sublocality, :administrative_area_level_2_short, 
      #   :administrative_area_level_1_short, :postal_code, :country_short, :lat, :lng, :place_id, 
      #   :landlord => [:code, :name, :contact_name, :mobile, :office_phone, :fax, 

      data
    end

  end