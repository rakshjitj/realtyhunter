
namespace :maintenance do
	desc "Update parent amenity id for residential amenities"
	task :update_parent_neighborhood_id => :environment do
		log = ActiveSupport::Logger.new('log/update_parent_neighborhood_id.log')
		start_time = Time.now

		puts "Update parent_neighborhood_id..."
		log.info "Update parent_neighborhood_id..."

		@neighborhood = Neighborhood.all
		@neighborhood.each do |negh|
			a = ["29", "35", "23", "47", "45", "22", "8", "41", "3", "1", "13", "24", "5", "30", "43", "6", "21", "34", "46", "18", "38", "28", "17", "4", "52", "26", "37", "2", "19", "25", "39", "31"]
			if a.include? negh.id.to_s
				negh.update(parent_neighborhood_id: 54)
			end
			b = ["9", "11", "10", "40", "48", "15", "27", "16", "20", "7", "32", "12", "53", "14"]
			if b.include? negh.id.to_s
				negh.update(parent_neighborhood_id: 55)
			end
			c = ["49", "33", "36"]
			if c.include? negh.id.to_s
				negh.update(parent_neighborhood_id: 56)
			end
			d = ["42", "51", "50", "44"]
			if d.include? negh.id.to_s
				negh.update(parent_neighborhood_id: 57)
			end
			# unit.update_columns(streeteasy_listing_email: 'info@myspacenyc.com', streeteasy_listing_number: '917-974-9359')
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
