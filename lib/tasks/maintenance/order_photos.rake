namespace :maintenance do
	desc "clean up to match latest schema changes"
	task :order_photos => :environment do
		log = ActiveSupport::Logger.new('log/import_landlords.log')
		start_time = Time.now

	  company = Company.find_by(name: 'MyspaceNYC')

		puts "Updating photo priority..."
		log.info "Updating photo priority..."

		company.buildings.each {|b|
			Image.reorder_by_building(b.id)

			units, unit_images = b.residential_units
			units.each {|r|
				Image.reorder_by_unit(r.id)
			}
		}

		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end