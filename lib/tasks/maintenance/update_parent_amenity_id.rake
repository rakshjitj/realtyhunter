
namespace :maintenance do
	desc "Update parent amenity id for residential amenities"
	task :update_parent_amenity_id => :environment do
		log = ActiveSupport::Logger.new('log/update_parent_amenity_id.log')
		start_time = Time.now

		puts "Update update_parent_amenity_id..."
		log.info "Update update_parent_amenity_id..."

		@residential_amenities = ResidentialAmenity.all
		@residential_amenities.each do |ra|
			a = ["89", "118", "128", "142", "132", "90", "131", "2"]
			if a.include? ra.id.to_s
				ra.update(parent_amenity_id: 145)
			end
			b = ["5", "84", "3", "4", "103", "106"]
			if b.include? ra.id.to_s
				ra.update(parent_amenity_id: 146)
			end
			c = ["100", "75", "105", "134", "14", "140", "73", "120", "71", "96", "15", "16", "20", "21"]
			if c.include? ra.id.to_s
				ra.update(parent_amenity_id: 147)
			end
			d = ["87", "125", "6", "129", "112", "70", "76", "82", "77", "127", "72", "117", "8", "101", "102", "122", "9", "86", "93", "107"]
			if d.include? ra.id.to_s
				ra.update(parent_amenity_id: 148)
			end
			e = ["123", "113", "92", "135", "85", "88", "91", "95", "99", "126", "116", "98", "18", "81", "144", "1"]
			if e.include? ra.id.to_s
				ra.update(parent_amenity_id: 149)
			end
			f = ["83", "143", "97", "141", "139"]
			if f.include? ra.id.to_s
				ra.update(parent_amenity_id: 150)
			end
			g = ["119", "11", "12", "68", "114", "130"]
			if g.include? ra.id.to_s
				ra.update(parent_amenity_id: 151)
			end
			h = ["115", "110", "69", "78", "124", "109", "7", "94", "121", "79", "80", "17", "19"]
			if h.include? ra.id.to_s
				ra.update(parent_amenity_id: 152)
			end
			i = ["104", "133", "108"]
			if i.include? ra.id.to_s
				ra.update(parent_amenity_id: 153)
			end
			j = ["136", "137", "138"]
			if j.include? ra.id.to_s
				ra.update(parent_amenity_id: 154)
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
