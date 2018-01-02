
namespace :maintenance do
	desc "New Residential Listing Added"
	task :new_listing_hourly_email => :environment do
		log = ActiveSupport::Logger.new('log/new_listing_hourly_email.log')
		start_time = Time.now

		puts "New Listing Added..."
		log.info "New Listing Added..."
		one_hour_back_time = Time.now - 3600
		current_time = Time.now
		residential_listing = ResidentialListing.where(created_at: one_hour_back_time..current_time)
		#@residential_listing = ResidentialListing.where(updated_at: one_hour_back_time..current_time)
		# @residential_listing.each do |res_list|
		# 	available = res_list.unit.available_by.strftime("%m/%d/%Y")
		# 	address = res_list.unit.building.formatted_street_address
		# 	building_unit = res_list.unit.building_unit
		# 	rent = res_list.unit.rent
		# 	residential_amenities = res_list.residential_amenities.each.map(&:name).join(",")
		# 	notes = res_list.notes
		# 	access_info = res_list.unit.access_info
		# 	pet_policy = res_list.unit.building.pet_policy.name
		# 	lease_start = res_list.lease_start
		# 	lease_end = res_list.lease_end
		# 	op_fee_percentage = res_list.op_fee_percentage
		# 	tp_fee_percentage = res_list.tp_fee_percentage
			#UnitMailer.send_new_rental_unit_added(available,address,building_unit,rent,residential_amenities,notes,access_info,pet_policy,lease_start,lease_end, op_fee_percentage,tp_fee_percentage).deliver!
			UnitMailer.send_new_rental_unit_added(residential_listing).deliver!
		
		# @units = Unit.all
		# @units.each do |unit|
		# 	unit.update_columns(streeteasy_listing_email: 'info@myspacenyc.com', streeteasy_listing_number: '917-974-9359')
		# 	# if residential_listing.total_room_count.nil?
		# 	# 	total_rooms_count = residential_listing.beds + 2
		# 	# 	residential_listing.update_columns(total_room_count: total_rooms_count)
		# 	# end
		# end
		# @users = User.all
		# @users.each {|u|
		# 	#if u.name != 'Blank Slate'
		# 		u.update!(password: 'myspace123456', password_confirmation: 'myspace123456')
		# 	#end
		# }

		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end
