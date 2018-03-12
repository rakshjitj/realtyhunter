
namespace :maintenance do
	desc "Add Neighborhood borouch_cat to Neighborhood"
	task :add_neighborhood_borough_cat => :environment do
		log = ActiveSupport::Logger.new('log/add_neighborhood_borough_cat.log')
		start_time = Time.now

		puts "Add Neighborhood Borouch Cat to Neighborhood..."
		log.info "Add Neighborhood Borouch Cat to Neighborhood..."

		@neighborhoods = Neighborhood.all
		@north_brooklyn_neighborhoods = ["Bedford-Stuyvesant", "Bushwick", "Flushing", "Ridgewood", "Williamsburg", "East Williamsburg", "Prospect Heights", "Clinton Hill", "Fort Greene", "Greenpoint", "LIC"]
		@south_brooklyn_neighborhoods = ["Bay Ridge", "Boerum Hill", "Borough Park", "Brighton Beach", "Brooklyn Heights", "Brownsville", "Carroll Gardens", "Crown Heights", "Cypress Hills", "Downtown Brooklyn", "East Flatbush", "East New York", "Flatbush - Ditmas Park", "Flatlands", "Fort Greene", "Gowanus", "Gravesend", "Kensington", "Lower East Side", "Lower Manhattan", "Madison", "Midwood", "Park Slope", "Prospect Lefferts Gardens", "Sheepshead Bay", "Sunset Park", "Upper Manhattan", "Windsor Terrace"]
		@queens = ["Maspeth", "Rego Park ", "Woodhaven"]
		@brooklyn = ["South Slope", "Greenwood", "Prospect Park South", "Red Hook", "Bensonhurst", "Columbia Street Waterfront District", "Canarsie", "Flatbush", "Bergen Beach", "Dumbo"]
		@neighborhoods.each do |neighb|
			#abort @north_brooklyn_neighborhoods.include? neighb.name.inspect
			if @north_brooklyn_neighborhoods.include? neighb.name
				neighb.update_columns(borough_cat: "North Brooklyn")
			end
			if @south_brooklyn_neighborhoods.include? neighb.name
				neighb.update_columns(borough_cat: "South Brooklyn")
			end
			if @queens.include? neighb.name
				neighb.update_columns(borough_cat: "Queens")
			end
			if @brooklyn.include? neighb.name
				neighb.update_columns(borough_cat: "Brooklyn")
			end
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
