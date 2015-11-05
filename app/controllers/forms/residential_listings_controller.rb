module Forms
	class ResidentialListingsController < ApplicationController
		skip_authorize_resource
  	before_action :set_entry, except: [:index, :new, :create, :filter, 
			:download, :send_update, :unarchive, :unarchive_modal, :destroy, :delete_modal]
		autocomplete :wufoo_listings_form, :name, where: {is_residential: true}, full: true
		autocomplete :wufoo_listings_form, :email, where: {is_residential: true}, full: true

		def index
			params[:status] = 'Active'
			set_entries
		end

		def download
	  	ids = params[:entry_ids].split(',')
	  	@entries = WufooListingsForm.residential
      	.where(id: ids)
	    
	  	respond_to do |format|
	      format.csv do
	        headers['Content-Disposition'] = "attachment; filename=\"residential-listings-form-data.csv\""
	        headers['Content-Type'] ||= 'text/csv'
	      end
	      format.pdf do
	      	render pdf: current_user.company.name + ' - Residential Listings Form Data - ' + Date.today.strftime("%b%d%Y"),
	          template: "/forms/residential_listings/download.pdf.erb",
	          orientation: 'Landscape',
	          layout:   "/layouts/pdf_layout.html"
	      end
	    end
	  end

	  def send_message
	    recipients = residential_listings_params[:email_modal][:recipients].split(/\s, \,/)
	    sub = residential_listings_params[:email_modal][:title]
	    msg = residential_listings_params[:email_modal][:message]
	    WufooListingsForm.send_message(current_user, recipients, sub, msg)
	    
	    respond_to do |format|
	      format.js { flash[:success] = "Message sent!"  }
	    end
	  end

	  def filter
	    set_entries
	    respond_to do |format|
	      format.js  
	    end
	  end

	  def detail_modal
	  	respond_to do |format|
	      format.js  
	    end
	  end
	  
	  def delete_modal
	  	@entry = WufooListingsForm.find(params[:id])
	    respond_to do |format|
	      format.js  
	    end
	  end

	  def destroy
	  	@entry = WufooListingsForm.find(params[:id])
	    @entry.delete
	    set_entries
	    respond_to do |format|
	      format.html { redirect_to forms_residential_listings_url, notice: 'Entry was successfully inactivated.' }
	      format.json { head :no_content }
	      format.js
	    end
	  end

	  def hide_modal
	    respond_to do |format|
	      format.js  
	    end
	  end

	  def hide
			@entry.archive
	    set_entries
	    respond_to do |format|
	      format.html { redirect_to forms_residential_listings_url, notice: 'Entry was successfully inactivated.' }
	      format.json { head :no_content }
	      format.js
	    end
	  end

	  def unarchive_modal
	  	@entry = WufooListingsForm.residential.find(params[:id])
	    respond_to do |format|
	      format.js  
	    end
	  end

	  def unarchive
	  	@entry = WufooListingsForm.residential.find(params[:id])
	  	@entry.unarchive
	  	params[:status] = 'Hidden'
	    set_entries
	    respond_to do |format|
	      format.html { redirect_to forms_residential_listings_url, notice: 'Entry was successfully activated.' }
	      format.json { head :no_content }
	      format.js
	    end
	  end

		private
			def set_entry
				@entry = WufooListingsForm.residential.find_unarchived(params[:id])
	    rescue ActiveRecord::RecordNotFound
	      flash[:warning] = "Sorry, that entry is not active."
	      redirect_to :action => 'index'
			end

			def set_entries
				if params[:status].blank?
					params[:status] = 'Active'
				end
				@entries = WufooListingsForm.residential.search(residential_listings_params)
				@entries = custom_sort
		    @entries = @entries.page params[:page]
		    @entries
			end

			def custom_sort
	      sort_column = params[:sort_by] || "created_at"
	      sort_order = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
	      params[:sort_by] = sort_column
	      params[:direction] = sort_order
	      @entries = @entries.order(sort_column + ' ' + sort_order)
	      @entries
	  	end

	  	def residential_listings_params
	  		data = params.permit(:sort_by, :direction, :filter, :name, :status, :entry_ids, 
	  			:message, :email, :submitted_date, 
	  			email_modal: [:title, :message, :recipients])
	  	end
	end
end