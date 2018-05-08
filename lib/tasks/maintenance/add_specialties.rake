namespace :maintenance do
	desc "clean up to match latest schema changes"
	task :add_specialties => :environment do
		log = ActiveSupport::Logger.new('log/add_specialties.log')
		start_time = Time.now

		puts "add specialties..."
		log.info "add specialties..."

		Specialty.create(name: "Bay Ridge", company_id: 1)
		Specialty.create(name: "Bedford Stuyvesant", company_id: 1)
		Specialty.create(name: "Bensonhurst", company_id: 1)
		Specialty.create(name: "Bergen Beach", company_id: 1)
		Specialty.create(name: "Boerum Hill", company_id: 1)
		Specialty.create(name: "Borough Park", company_id: 1)
		Specialty.create(name: "Brighton Beach", company_id: 1)
		Specialty.create(name: "Brooklyn Heights", company_id: 1)
		Specialty.create(name: "Brownsville", company_id: 1)
		Specialty.create(name: "Bushwick", company_id: 1)
		Specialty.create(name: "Canarsie", company_id: 1)
		Specialty.create(name: "Carroll Gardens", company_id: 1)
		Specialty.create(name: "Clinton Hill", company_id: 1)
		Specialty.create(name: "Columbia Street Waterfront District", company_id: 1)
		Specialty.create(name: "Crown Heights", company_id: 1)
		Specialty.create(name: "Cypress Hills", company_id: 1)
		Specialty.create(name: "Downtown Brooklyn", company_id: 1)
		Specialty.create(name: "Dumbo", company_id: 1)
		Specialty.create(name: "East Flatbush", company_id: 1)
		Specialty.create(name: "East New York", company_id: 1)
		Specialty.create(name: "East Williamsburg", company_id: 1)
		Specialty.create(name: "Flatbush - Ditmas Park", company_id: 1)
		Specialty.create(name: "Flatlands", company_id: 1)
		Specialty.create(name: "Flushing", company_id: 1)
		Specialty.create(name: "Fort Greene", company_id: 1)
		Specialty.create(name: "Gowanus", company_id: 1)
		Specialty.create(name: "Gravesend", company_id: 1)
		Specialty.create(name: "Greenpoint", company_id: 1)
		Specialty.create(name: "Greenwood", company_id: 1)
		Specialty.create(name: "Kensington", company_id: 1)
		Specialty.create(name: "LIC", company_id: 1)
		Specialty.create(name: "Lower East Side", company_id: 1)
		Specialty.create(name: "Lower Manhattan", company_id: 1)
		Specialty.create(name: "Madison", company_id: 1)
		Specialty.create(name: "Maspeth", company_id: 1)
		Specialty.create(name: "Midwood", company_id: 1)
		Specialty.create(name: "Park Slope", company_id: 1)
		Specialty.create(name: "Prospect Heights", company_id: 1)
		Specialty.create(name: "Prospect Lefferts Gardens", company_id: 1)
		Specialty.create(name: "Prospect Park South", company_id: 1)
		Specialty.create(name: "Red Hook", company_id: 1)
		Specialty.create(name: "Rego Park", company_id: 1)
		Specialty.create(name: "Ridgewood", company_id: 1)
		Specialty.create(name: "Sheepshead Bay", company_id: 1)
		Specialty.create(name: "South Slope", company_id: 1)
		Specialty.create(name: "Sunset Park", company_id: 1)
		Specialty.create(name: "Upper Manhattan", company_id: 1)
		Specialty.create(name: "Williamsburg", company_id: 1)
		Specialty.create(name: "Windsor Terrace", company_id: 1)
		Specialty.create(name: "Woodhaven", company_id: 1)
		Specialty.create(name: "Rentals", company_id: 1)
		Specialty.create(name: "Sales", company_id: 1)
		Specialty.create(name: "Retail", company_id: 1)
		Specialty.create(name: "Rooms", company_id: 1)

		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end