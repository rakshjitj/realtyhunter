namespace :maintenance do
	desc "Gets all listings with no primary agent"
	task :unassigned_listings => :environment do
		log = ActiveSupport::Logger.new('log/update_listing_agent.log')
		start_time = Time.now

	  company = Company.find_by(name: 'MyspaceNYC')

		puts "Getting listings without primary agents..."
		log.info "Getting listings without primary agents..."

		@units = ResidentialListing.joins(unit: :building)
			.where('units.archived = false')
			.where("units.status = ?", Unit.statuses['active'])
			.order('buildings.street_number')

		@units.each {|u|
			if u.unit && !u.unit.primary_agent
				puts u.street_address_and_unit
			end
		}

		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end