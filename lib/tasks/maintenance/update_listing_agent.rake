namespace :maintenance do
	desc "clean up to match latest schema changes"
	task :update_listing_agent => :environment do
		log = ActiveSupport::Logger.new('log/update_listing_agent.log')
		start_time = Time.now

	  company = Company.find_by(name: 'MyspaceNYC')

		puts "Updating listing agent info..."
		log.info "Updating listing agent info..."


		@landlords = Landlord.all
		@landlords.each{|l| 
			perc = l.listing_agent_percentage
			l.buildings.each{|b|
				b.listing_agent_percentage = perc
				b.save!
			}
		}

		@units = ResidentialUnit.all
		@units.each {|u|
			has_fee = u.has_fee
			op = u.op_fee_percentage
			tp = u.tp_fee_percentage

			# will be overwritten many times
			bldg = u.unit.building
			if bldg.op_fee_percentage || bldg.tp_fee_percentage
				# has already been updated, so skip
				next
			end

			bldg.has_fee = has_fee
			bldg.op_fee_percentage = op
			bldg.tp_fee_percentage = tp
			bldg.save!
		}

		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end