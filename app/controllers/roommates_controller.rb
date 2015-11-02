class RoommatesController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => :create
  before_action :set_roommate, except: [:index, :new, :create, :filter, 
    :download, :send_update, :unarchive, :unarchive_modal, :send_message, 
    :autocomplete_user_email, :autocomplete_roommate_name]
  autocomplete :roommate, :name, full: true
  autocomplete :user, :email, full: true

  def index
    set_roommates
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
        headers['Content-Disposition'] = "attachment; filename=\"roommates-list.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
      format.pdf do
      	render pdf: current_user.company.name + ' - Roommates - ' + Date.today.strftime("%b%d%Y"),
          template: "/roommates/download.pdf.erb",
          orientation: 'Landscape',
          layout:   "/layouts/pdf_layout.html"
      end
    end
  end

  def send_message
    recipients = roommate_params[:roommate][:recipients].split(/\s, \,/)
    sub = roommate_params[:roommate][:title]
    msg = roommate_params[:roommate][:message]
    roommate_ids = roommate_params[:roommate][:ids]
    Roommate.send_message(current_user, recipients, sub, msg, roommate_ids)
    
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
    @roommate = Roommate.find(params[:id])
    respond_to do |format|
      format.js  
    end
  end

  def unarchive
    @roommate = Roommate.find(params[:id])
    @roommate.unarchive
    params[:status] = 'Matched'
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

  protected

    def correct_stale_record_version
      @roommate.reload
      params[:roommate].delete('lock_version')
    end

  private
  	def set_roommate
      @roommate = Roommate.find_unarchived(params[:id])
      puts "SETTING ROOMMATE #{@roommate.inspect}"
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

      # set a default status if none otherwise specified
      if params[:status].blank?
        params[:status] = 'Unmatched'
      end

      @roommates = Roommate.search(params)
      @roommates = custom_sort
      @roommates = @roommates.page params[:page]
  	end

  	def custom_sort
      sort_column = params[:sort_by] || "submitted_date"
      sort_order = %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
      params[:sort_by] = sort_column
      params[:direction] = sort_order
      @roommates = @roommates.order(sort_column + ' ' + sort_order)
      @roommates
  	end

    def roommate_params
    	data = params.permit(:sort_by, :filter, :direction, :name, :referred_by, :neighborhood_id,
        :submitted_date, :move_in_date, :monthly_budget, :status,
        :dogs_allowed, :cats_allowed,
        roommate: [:lock_version, :name, :phone_number, :internal_notes,
          :email, :how_did_you_hear_about_us, :upload_picture_of_yourself, :describe_yourself,
          :monthly_budget, :move_in_date, :neighborhood, :dogs_allowed, :cats_allowed,
          :user_id, :recipients, :title, :message, :ids])

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