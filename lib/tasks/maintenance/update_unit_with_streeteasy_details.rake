
namespace :maintenance do
	desc "Update streeteasy listing email and number for units"
	task :update_unit_with_streeteasy_details => :environment do
		log = ActiveSupport::Logger.new('log/update_unit_with_streeteasy_details.log')
		start_time = Time.now

		puts "Update streeteasy listing email and number..."
		log.info "Update streeteasy listing email and number..."

		@units = Unit.all
		@units.each do |unit|
			unit.update_columns(streeteasy_listing_email: 'info@myspacenyc.com', streeteasy_listing_number: '917-974-9359')
			# if residential_listing.total_room_count.nil?
			# 	total_rooms_count = residential_listing.beds + 2
			# 	residential_listing.update_columns(total_room_count: total_rooms_count)
			# end
		end
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
