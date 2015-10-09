module Forms
	class ContactUsController < ApplicationController
		#load_and_authorize_resource
	  #skip_load_resource :only => :create
		before_action :set_entry, except: [:index, :new, :create, :filter, 
			:download, :send_update, :unarchive, :unarchive_modal]
		autocomplete :wufoo_contact_us_form, :name, full: true

		def index
			params[:status] = 'Active'
			set_entries
		end

		def download
	  	ids = params[:entry_ids].split(',')
	  	@entries = WufooContactUsForm
      	.where(id: ids)
	    
	  	respond_to do |format|
	      format.csv do
	        headers['Content-Disposition'] = "attachment; filename=\"contact-us-data.csv\""
	        headers['Content-Type'] ||= 'text/csv'
	      end
	      format.pdf do
	      	render pdf: current_user.company.name + ' - Contact Us Data - ' + Date.today.strftime("%b%d%Y"),
	          template: "/forms/contact_us/download.pdf.erb",
	          orientation: 'Landscape',
	          layout:   "/layouts/pdf_layout.html"
	      end
	    end
	  end

	  def send_message
	    recipients = contact_us_params[:recipients].split(/\s, \,/)
	    sub = contact_us_params[:title]
	    msg = contact_us_params[:message]
	    WufooContactUsForm.send_message(current_user, recipients, sub, msg)
	    
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

	  def delete_modal
	    respond_to do |format|
	      format.js  
	    end
	  end

	  def destroy
	    @entry.archive
	    set_entries
	    respond_to do |format|
	      format.html { redirect_to forms_contact_u_url, notice: 'Entry was successfully inactivated.' }
	      format.json { head :no_content }
	      format.js
	    end
	  end

	  def unarchive_modal
	  	@entry = WufooContactUsForm.find(params[:id])
	    respond_to do |format|
	      format.js  
	    end
	  end

	  def unarchive
	  	@entry = WufooContactUsForm.find(params[:id])
	  	@entry.unarchive
	    set_entries
	    respond_to do |format|
	      format.html { redirect_to forms_contact_u_url, notice: 'Entry was successfully activated.' }
	      format.json { head :no_content }
	      format.js
	    end
	  end

		private
			def set_entry
				@entry = WufooContactUsForm.find_unarchived(params[:id])
	    rescue ActiveRecord::RecordNotFound
	      flash[:warning] = "Sorry, that entry is not active."
	      redirect_to :action => 'index'
			end

			def set_entries
				@entries = WufooContactUsForm.search(contact_us_params)
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

	  	def contact_us_params
	  		data = params.permit(:sort_by, :filter, :name, :status, :min_price, :max_price, 
	  			:entry_ids, :submitted_date,
	  			contact_us: [:title, :message, :recipients])
	  	end
	end
end