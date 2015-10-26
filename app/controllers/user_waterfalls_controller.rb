class UserWaterfallsController < ApplicationController
	load_and_authorize_resource
  skip_load_resource :only => :create
	before_action :set_user_waterfall, only: [:show, :edit, :update, :destroy, :delete_modal]
	#autocomplete :user_waterfall, :parent_agent, full: true
	#autocomplete :user_waterfall, :child_agent, full: true
	autocomplete :user, :name, full: true

	def index
    set_user_waterfalls
    @new_entry = UserWaterfall.new
  end

  def filter
  	set_user_waterfalls
  	@new_entry = UserWaterfall.new
    respond_to do |format|
      format.js
    end
  end

  # def show
    
  # end

  # def edit

  # end

  def create
  	@entry = UserWaterfall.new(user_waterfall_params[:user_waterfall])
  	respond_to do |format|
  		if @entry.save
  			@new_entry = UserWaterfall.new
  			set_user_waterfalls
  			#format.html { redirect_to @entry, notice: 'Entry was successfully created.' }
        #format.json { render action: 'show', status: :created, location: @entry }
        format.js #  { render action: 'show', status: :created, location: @entry }
      else
      	puts @entry.errors.messages
      	#format.html { render action: 'index' }
        #format.json { render json: @entry.errors, status: :unprocessable_entity }
        format.js  # { render json: @entry.errors, status: :unprocessable_entity }
      end
  	end
  end

  def get_rate
  	@rate = UserWaterfall.get_rate(user_waterfall_params)
  	respond_to do |format|
      format.js  
    end
  end

  def delete_modal
    respond_to do |format|
      format.js  
    end
  end

  def destroy
  	@entry.archive
    set_user_waterfalls
    @new_entry = UserWaterfall.new
    respond_to do |format|
      format.html { redirect_to user_waterfall_url, notice: 'Waterfall connection was successfully removed.' }
      format.json { head :no_content }
      format.js
    end
  end

  private

  	def set_user_waterfall
  		@entry = UserWaterfall.find_unarchived(params[:id])
  	end

  	def set_user_waterfalls
  		# default to searching for active units
      # if !params[:level]
      #   params[:level] = "any"
      # end

  		@entries = UserWaterfall.search(user_waterfall_params)
  		@entries = @entries.page params[:page]
  		custom_sort
  	end

  	def custom_sort
      sort_column = params[:sort_by] || "updated_at"
      sort_order = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
      # reset params so that view helper updates correctly
      params[:sort_by] = sort_column
      params[:direction] = sort_order
      # if sorting by an actual db column, use order
      @entries = @entries.order(sort_column + ' ' + sort_order)
      @entries
    end

  	def user_waterfall_params
  		params.permit(:direction, :sort_by, :rate, :level, 
  			:parent_agent, :child_agent, :parent_agent_id, :child_agent_id, :id,
  			user_waterfall: [:rate, :level, :parent_agent_id, :child_agent_id, :id])
  	end

end
