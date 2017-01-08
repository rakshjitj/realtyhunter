namespace :maintenance do
	desc "units with no photos"
	task :units_with_no_photos => :environment do
		log = ActiveSupport::Logger.new('log/units_with_no_photos.log')
		start_time = Time.now

	  company = Company.find_by(name: 'MyspaceNYC')

		puts "Units with no photos:"
		log.info "Units with no photos:"


		for unit in Unit.joins(:building).order('buildings.formatted_street_address asc')
			if unit.images.empty?
				output = ''

				if unit.residential_listing
					output = 'Residential ID:[' + unit.residential_listing.id.to_s + '] '
				elsif unit.commercial_listing
					output = 'Commercial ID:[' + unit.commercial_listing.id.to_s + '] '
				elsif unit.sales_listing
					output = 'Sales ID:[' + unit.sales_listing.id.to_s + '] '
				end
				output += unit.building.street_address
				if !unit.building_unit.empty?
					output += ' #' + unit.building_unit + "\n"
				end

				puts output
				log.info output
			end
		end

		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end
