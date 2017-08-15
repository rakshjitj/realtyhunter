namespace :maintenance do
	desc "Update total room count for residential and sales listing"
	task :update_total_room_count => :environment do
		log = ActiveSupport::Logger.new('log/total_rooms_count.log')
		start_time = Time.now

		puts "Update total rooms count..."
		log.info "Update total rooms count..."

		@residential_listing = ResidentialListing.all
		@residential_listing.each do |residential_listing|
			if residential_listing.total_room_count.nil?
				total_rooms_count = residential_listing.beds + 2
				residential_listing.update_columns(total_room_count: total_rooms_count)
			end
		end
		@sale_listing = SalesListing.all
		@sale_listing.each do |sale_listing|
			if sale_listing.total_room_count.nil?
				total_rooms_count = sale_listing.beds + 2
				sale_listing.update_columns(total_room_count: total_rooms_count)
			end
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
