namespace :maintenance do
	desc "update total_active_units, total_units, and last update fields for buildings"
	task populate_count_fields: :environment do
		log = ActiveSupport::Logger.new('log/populate_bldg_counts.log')
		start_time = Time.now

		Building.all.each do |bldg|
			puts "Updating building [#{bldg.id}]"
      bldg.update_total_unit_count
      bldg.update_active_unit_count

			if bldg.units.length > 0
				bldg.update_attributes(last_unit_updated_at: bldg.units.unarchived.first.updated_at)
			end
		end

		Landlord.all.each do |ll|
			puts "Updating landlord [#{ll.id}]"
			ll.update_total_unit_count
      ll.update_active_unit_count

      bldgs = ll.buildings.joins(:units).order('updated_at DESC')
      if bldgs.count > 0
      	ll.update_attributes(last_unit_updated_at: bldgs.unarchived.first.updated_at)
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
