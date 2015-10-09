module Forms
	class PartnerController < ApplicationController
		skip_authorize_resource
  	before_action :set_entry, except: [:index, :new, :create, :filter, 
			:download, :send_update, :unarchive, :unarchive_modal]
		autocomplete :wufoo_partner_form, :name, full: true

		def index
			params[:status] = 'Active'
			set_entries
		end

		def download
	  	ids = params[:entry_ids].split(',')
	  	@entries = WufooPartnerForm
      	.where(id: ids)
	    
	  	respond_to do |format|
	      format.csv do
	        headers['Content-Disposition'] = "attachment; filename=\"partner-with-us-data.csv\""
	        headers['Content-Type'] ||= 'text/csv'
	      end
	      format.pdf do
	      	render pdf: current_user.company.name + ' - Partner With Us Data - ' + Date.today.strftime("%b%d%Y"),
	          template: "/forms/partner/download.pdf.erb",
	          orientation: 'Landscape',
	          layout:   "/layouts/pdf_layout.html"
	      end
	    end
	  end

	  def send_message
	    recipients = partner_params[:recipients].split(/\s, \,/)
	    sub = partner_params[:title]
	    msg = partner_params[:message]
	    WufooPartnerForm.send_message(current_user, recipients, sub, msg)
	    
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
	    respond_to do |format|
	      format.js  
	    end
	  end

	  def destroy
	    @entry.archive
	    set_entries
	    respond_to do |format|
	      format.html { redirect_to forms_partner_index_url, notice: 'Entry was successfully inactivated.' }
	      format.json { head :no_content }
	      format.js
	    end
	  end

	  def unarchive_modal
	  	@entry = WufooPartnerForm.find(params[:id])
	    respond_to do |format|
	      format.js  
	    end
	  end

	  def unarchive
	  	@entry = WufooPartnerForm.find(params[:id])
	  	@entry.unarchive
	    set_entries
	    respond_to do |format|
	      format.html { redirect_to forms_partner_index_url, notice: 'Entry was successfully activated.' }
	      format.json { head :no_content }
	      format.js
	    end
	  end

		private
			def set_entry
				@entry = WufooPartnerForm.find_unarchived(params[:id])
	    rescue ActiveRecord::RecordNotFound
	      flash[:warning] = "Sorry, that entry is not active."
	      redirect_to :action => 'index'
			end

			def set_entries
				@entries = WufooPartnerForm.search(partner_params)
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

	  	def partner_params
	  		data = params.permit(:sort_by, :direction, :filter, :name, :status, :min_price, :max_price, 
	  			:entry_ids, :submitted_date, 
	  			contact_us: [:title, :message, :recipients])
	  	end
	end
end