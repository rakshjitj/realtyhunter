module Forms
	class CareersController < ApplicationController
		skip_authorize_resource
  	before_action :set_entry, except: [:index, :new, :create, :filter,
			:download, :send_update, :unarchive, :unarchive_modal, :detail_modal,
			:destroy, :delete_modal, :destroy_multiple, :destroy_multiple_modal]
		autocomplete :wufoo_career_form, :name, full: true

		def index
			params[:status] = 'Active'
			set_entries
		end

		def download
	  	ids = params[:entry_ids].split(',')
	  	@entries = WufooCareerForm.where(id: ids)

	  	respond_to do |format|
	      format.csv do
	        headers['Content-Disposition'] = "attachment; filename=\"careers-data.csv\""
	        headers['Content-Type'] ||= 'text/csv'
	      end
	      format.pdf do
	      	render pdf: current_user.company.name + ' - Careers Data - ' + Date.today.strftime("%b%d%Y"),
	          template: "/forms/careers/download.pdf.erb",
	          orientation: 'Landscape',
	          layout:   "/layouts/pdf_layout.html"
	      end
	    end
	  end

	  def send_message
	    recipients = careers_params[:email_modal][:recipients].split(/\s, \,/)
	    sub = careers_params[:email_modal][:title]
	    msg = careers_params[:email_modal][:message]
	    WufooCareerForm.send_message(current_user.id, recipients, sub, msg)

	    respond_to do |format|
	      format.js { flash[:success] = "Message sent!" }
	    end
	  end

	  def mark_read
	    if WufooCareerForm.mark_read(params[:ids])
	      params.delete('ids')
	      set_entries
	      flash[:success] = 'Entries marked as read.'
	      respond_to do |format|
	        format.html { redirect_to forms_careers_url }
	        format.json { head :no_content }
	        format.js
	      end
	    else
	      set_entries
	      flash[:danger] = 'Entries could not marked read.'
	    end
	  end

	  def filter
	    set_entries
	    respond_to do |format|
	      format.js
	      format.html { redirect_to forms_careers_url }
	    end
	  end

	  def detail_modal
	  	@entry = WufooCareerForm.find(params[:id])
	  	WufooCareerForm.mark_read(params[:id])
	  	set_entries
	  	respond_to do |format|
	      format.js
	      format.html { redirect_to forms_careers_url }
	    end
	  end

	  def delete_modal
	  	@entry = WufooCareerForm.find(params[:id])
	  	@params_copy = params
	    @params_copy.delete('action')
	    @params_copy.delete('controller')
	    @params_copy.delete('id')
	    respond_to do |format|
	      format.js
	      format.html { redirect_to forms_careers_url }
	    end
	  end

	  def hide_modal
	  	@params_copy = params
	    @params_copy.delete('action')
	    @params_copy.delete('controller')
	    @params_copy.delete('id')
	    respond_to do |format|
	      format.js
	      format.html { redirect_to forms_careers_url }
	    end
	  end

	  def hide
	  	@entry.archive
	    set_entries
	    respond_to do |format|
	      format.html { redirect_to forms_careers_url, notice: 'Entry was successfully inactivated.' }
	      format.json { head :no_content }
	      format.js
	    end
	  end

	  def destroy
	  	@entry = WufooCareerForm.find(params[:id])
	    @entry.destroy
	    set_entries
	    respond_to do |format|
	      format.html { redirect_to forms_careers_url, notice: 'Entry was successfully inactivated.' }
	      format.json { head :no_content }
	      format.js
	    end
	  end

	  def destroy_multiple_modal
	    @entries = WufooCareerForm.where(id: params[:ids]).order('name asc')
	    respond_to do |format|
	      format.js
	      format.html { redirect_to forms_careers_url }
	    end
	  end

	  def destroy_multiple
	    if !params[:ids].blank?
	      WufooCareerForm.where(id: params[:ids]).destroy_all
	      params.delete('ids')
	    end
	    set_entries
	    respond_to do |format|
	      format.html { redirect_to forms_careers_url, notice: 'Entries were successfully deleted.' }
	      format.json { head :no_content }
	      format.js
	    end
	  end

	  def unarchive_modal
	  	@entry = WufooCareerForm.find(params[:id])
	    respond_to do |format|
	      format.js
	      format.html { redirect_to forms_careers_url }
	    end
	  end

	  def unarchive
	  	@entry = WufooCareerForm.find(params[:id])
	  	@entry.unarchive
	  	params[:status] = 'Hidden'
	    set_entries
	    respond_to do |format|
	      format.html { redirect_to forms_careers_url, notice: 'Entry was successfully activated.' }
	      format.json { head :no_content }
	      format.js
	    end
	  end

		private
			def set_entry
				@entry = WufooCareerForm.find_unarchived(params[:id])
	    rescue ActiveRecord::RecordNotFound
	      flash[:warning] = "Sorry, that entry is not active."
	      redirect_to action: 'index'
			end

			def set_entries
				if params[:status].blank?
					params[:status] = 'Active'
				end

				@entries = WufooCareerForm.search(careers_params)
				@entries = custom_sort
		    @entries = @entries.page params[:page]
		    @entries
			end

			def custom_sort
	      sort_column = params[:sort_by] || "created_at"
	      sort_order = %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
	      params[:sort_by] = sort_column
	      params[:direction] = sort_order
	      @entries = @entries.order(sort_column + ' ' + sort_order)
	      @entries
	  	end

	  	def careers_params
	  		data = params.permit(:sort_by, :direction, :filter, :name, :status, :licensed_agent, :id,
	  			:how_did_you_hear_about_use, :source, :what_neighborhood_do_you_live_in, :submitted_date,
	  			email_modal: [:title, :message, :recipients])
	  	end
	end
end
