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

		results = []
		@units.each {|u|
			if u.unit && !u.unit.primary_agent
				results << u.street_address_and_unit
			end
		}

		puts "Found #{results.count} results:"
		puts "\n" + results.join("\n")
		
		managers = ['sbrewer@myspacenyc.com', 'info@myspacenyc.com','rbujans@myspacenyc.com']
		UserMailer.send_unassigned_report(managers, results).deliver_now
		puts "Email sent to #{managers.inspect}"
		log.info "Email sent to #{managers.inspect}"

		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end