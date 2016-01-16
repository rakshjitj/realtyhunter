class UserWaterfallsController < ApplicationController
	load_and_authorize_resource
  skip_load_resource only: [:create, :show]
	before_action :set_user_waterfall, only: [:edit, :update, :destroy, :delete_modal, :edit_modal]
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

  def show
  	params[:parent_agent_id] = params[:id]
    @entries = UserWaterfall.search(params)
      .order('level asc')
      .to_a.group_by(&:level)
  end

  def create
    existing_entry = UserWaterfall.unarchived.where(
      parent_agent_id: user_waterfall_params[:user_waterfall][:parent_agent_id],
      child_agent_id: user_waterfall_params[:user_waterfall][:child_agent_id]).first
    @entry = UserWaterfall.new(user_waterfall_params[:user_waterfall])

    if existing_entry
      @duplication_error ="This connection has already been added."
    end

  	respond_to do |format|
  		if !existing_entry && @entry.save
  			@new_entry = UserWaterfall.new
  			set_user_waterfalls
        format.js
      else
        format.js
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

  def edit_modal
    respond_to do |format|
      format.js
    end
  end

  def update
    if @entry.update(user_waterfall_params[:user_waterfall].merge({updated_at: Time.now}))
      set_user_waterfalls
      #flash[:success] = "Waterfall connection updated!"
    end
    respond_to do |format|
      format.html { redirect_to user_waterfall_url, notice: 'Waterfall connection updated.' }
      format.json { head :no_content }
      format.js
    end
  end

  private

  	def set_user_waterfall
  		@entry = UserWaterfall.find_unarchived(params[:id])
  	end

  	def set_user_waterfalls
  		@entries = UserWaterfall.search(user_waterfall_params)
  		@entries = @entries.page params[:page]
  		custom_sort
  	end

  	def custom_sort
      sort_column = params[:sort_by] || "parent_agent_name"
      sort_order = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
      # reset params so that view helper updates correctly
      params[:sort_by] = sort_column
      params[:direction] = sort_order
      # if sorting by an actual db column, use order
      @entries = @entries.order(sort_column + ' ' + sort_order)
      @entries
    end

  	def user_waterfall_params
  		params.permit(:direction, :sort_by, :rate, :level, :agent_seniority_rate,
  			:parent_agent, :child_agent, :parent_agent_id, :child_agent_id, :id,
  			user_waterfall: [
          :rate, :level, :parent_agent_id, :child_agent_id,
          :agent_seniority_rate, :id])
  	end

end
