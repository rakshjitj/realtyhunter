
namespace :maintenance do
	desc "Update parent amenity id for building amenities"
	task :update_parent_building_amenities_id => :environment do
		log = ActiveSupport::Logger.new('log/update_parent_building_amenities_id.log')
		start_time = Time.now

		puts "Update update_parent_building_amenities_id..."
		log.info "Update update_parent_building_amenities_id..."

		@neighborhood = BuildingAmenity.all
		@neighborhood.each do |negh|
			a = ["49", "86", "55", "88", "79", "3", "13", "50", "69", "58", "22", "102", "89", "28", "35", "101", "29"]
			if a.include? negh.id.to_s
				negh.update(building_parent_amenity_id: 115)
			end
			b = ["5", "15", "82", "93", "9", "19", "7", "17"]
			if b.include? negh.id.to_s
				negh.update(building_parent_amenity_id: 116)
			end
			c = ["10", "20", "30", "53", "84", "27", "31", "85", "99", "36"]
			if c.include? negh.id.to_s
				negh.update(building_parent_amenity_id: 117)
			end
			d = ["6", "16", "105", "51", "87"]
			if d.include? negh.id.to_s
				negh.update(building_parent_amenity_id: 118)
			end
			e = ["32", "33", "72"]
			if e.include? negh.id.to_s
				negh.update(building_parent_amenity_id: 119)
			end
			f = ["100", "98", "114", "78", "111", "77", "113", "110", "103", "75"]
			if f.include? negh.id.to_s
				negh.update(building_parent_amenity_id: 120)
			end
			g = ["60", "104", "97", "1", "11", "54", "107", "61", "52", "80", "63", "48", "62", "2", "12"]
			if g.include? negh.id.to_s
				negh.update(building_parent_amenity_id: 121)
			end
			h = ["108", "112", "94", "109"]
			if h.include? negh.id.to_s
				negh.update(building_parent_amenity_id: 122)
			end
			i = ["65", "24", "57", "71", "8", "18", "106", "90", "34", "83", "92"]
			if i.include? negh.id.to_s
				negh.update(building_parent_amenity_id: 123)
			end
			j = ["64", "70", "26", "91", "76", "95", "74"]
			if j.include? negh.id.to_s
				negh.update(building_parent_amenity_id: 124)
			end
			k = ["56", "68", "73", "91", "81", "66", "67"]
			if k.include? negh.id.to_s
				negh.update(building_parent_amenity_id: 125)
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
