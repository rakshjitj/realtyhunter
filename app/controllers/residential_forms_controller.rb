# class ResidentialFormsController < ApplicationController
#   skip_authorize_resource
# 	#respond_to :html

#   def new
#     @panel_title = "Add a listing"
#   	@residential_form = ResidentialForm.new
#     #puts "\n\n\n ****HELLO #{@residential_form.inspect}"
#   end

#   def create
#     @residential_form = ResidentialForm.new(residential_form_params)
#     puts @residential_form.attributes.inspect

#   	new_rlisting = @residential_form.submit
#     puts "SUBMITTED OK #{@residential_form.listing}"
#     if @residential_form.listing
#       redirect_to @residential_form.listing
#     else
#       render 'new'
#     end
#   end

#   def edit
#     @panel_title = "Edit listing"
#     @residential_form = ResidentialForm.load(params[:id])
#   end

#   def update
#     @residential_form = ResidentialForm.new(residential_form_params)#.load(params[:id])
#     @residential_form.update(params[:id]) #hack
#     #puts "SUBMITTED OK #{@residential_form.listing}"
#     if @residential_form.listing
#       redirect_to @residential_form.listing
#     else
#       render 'edit'
#     end
#   end

#   private

#     def residential_form_params
#       #puts "---- #{params.inspect}"
#       data = params[:residential_form].permit(:id, :building_unit, :rent, 
#         :available_by, :tenant_occupied, :access_info, :status, :has_fee, 
#         :open_house, :oh_exclusive, :building_id, :primary_agent_id, 
#         :listing_agent_id, :beds, :baths, :notes, :description, :lease_start, 
#         :lease_end, :include_photos, :inaccuracy_description, 
#         :op_fee_percentage, :tp_fee_percentage, :available_starting, 
#         :available_before, :residential_amenity_ids => [])

#       if data[:oh_exclusive] == "1"
#         data[:oh_exclusive] = true
#       else
#         data[:oh_exclusive] = false
#       end

#       if data[:has_fee] == "1"
#         data[:has_fee] = true
#       else
#         data[:has_fee] = false
#       end

#       # convert into a datetime obj
#       if data[:available_by] && !data[:available_by].empty?
#         data[:available_by] = Date::strptime(data[:available_by], "%m/%d/%Y")
#       end

#       data
#     end

# end
