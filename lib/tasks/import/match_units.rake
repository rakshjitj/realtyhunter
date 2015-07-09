namespace :import do
	desc 'Matches imported Nestio residential units with imported Zillow landlords data'
	task match_units: :environment do
		require 'csv'

		log = ActiveSupport::Logger.new('log/import_match_units.log')
		start_time = Time.now

		puts "Analyzing data..."
		log.info "Analyzing data..."
		# columns look like this:
		# id, number, street, city, state, zip, unit_number, rent, beds, baths, date available,
		# notes, landlord_name, ...
		idx = 0
		CSV.foreach('lib/tasks/import/zillow_listings.csv', col_sep: ';') { |row| 
			street_number = row[1]
			route = row[2]
			bldg = Building.find_by(street_number: street_number, route: route)
			ll_code = row[12]
			if bldg && ll_code && !ll_code.empty?
				ll = Landlord.find_by(code: ll_code)
				if ll 
					puts "[#{idx}] #{bldg.street_address} - matched with #{bldg.landlord.code}"
					log.info "[#{idx}] #{bldg.street_address} - matched with #{bldg.landlord.code}"
					bldg.landlord = ll
					bldg.save
				else
					puts "[#{idx}] #{bldg.street_address} - landlord not found"
					log.info "[#{idx}] #{bldg.street_address} - landlord not found"
				end
			else
				puts "[#{idx}] #{street_number} #{route}- building not found"
				log.info "[#{idx}] #{street_number} #{route}- building not found"
			end

			idx = idx + 1
		}

		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end

end