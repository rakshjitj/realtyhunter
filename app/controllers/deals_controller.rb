class DealsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => :create
  before_action :set_deal, except: [:index, :new, :create, :filter, 
    :autocomplete_building_formatted_street_address]
  autocomplete :building, :formatted_street_address, full: true

	def index
		respond_to do |format|
      format.html do
        set_deals
      end
      format.csv do
        set_deals_csv
        headers['Content-Disposition'] = "attachment; filename=\"landlords-list.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
	end

	def show
	end

	def new
		@deal = Deal.new
	end

	def create
		@deal = Deal.new(deal_params)
		if @deal.save
			redirect_to @deal
		else
			render 'new'
		end
	end

	def edit
	end

	def update
		if @deal.udpate(deal_params)
			flash[:success] = "Deal updated!"
      redirect_to @deal
    else
    	render 'edit'
		end

	end

	def destroy
		@deal.archive
		set_deals
		respond_to do |format|
      format.html { redirect_to deals_url, notice: 'Deal was successfully destroyed.' }
      format.json { head :no_content }
      format.js
    end
	end

	def filter
    set_deals
    respond_to do |format|
      format.js
    end
  end

	protected
		def correct_stale_record_version
      @deal.reload
      params[:deal].delete('lock_version')
    end

  private

  	def set_deal
  		@deal = Deal.find_unarchived(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "Sorry, that deal is not active."
      redirect_to :action => 'index'
  	end

		def set_deals
      puts deals_params
			@deals = Deal.search(deals_params)
      @deals = custom_sort
			@deals = @deals.page params[:page]
		end

		def set_deals_csv
			@deals = Deal.search_csv(deals_params)
			@deals = custom_sort
		end

		def custom_sort
      sort_column = params[:sort_by] || "closed_date"
      sort_order = %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
      params[:sort_by] = sort_column
      params[:direction] = sort_order
      #if Deal.column_names.include?(params[:sort_by])
      @deals = @deals.order(sort_column + ' ' + sort_order)
      #end
      @deals
    end

    def deals_params
    	params.permit(:sort_by, :direction, :address, :agent, :closed_date_start, :closed_date_end,
    		deal: [:price, :client, :lease_term, :lease_start_date, :lease_expiration_date,
    			:closed_date, :move_in_date, :commission, :deal_notes, :listing_type, :is_sale_deal, 
    			:unit_id, :agent_id])
    end

end