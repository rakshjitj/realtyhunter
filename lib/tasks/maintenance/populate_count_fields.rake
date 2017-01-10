namespace :maintenance do
	desc "update total_active_units, total_units, and last update fields for buildings"
	task populate_count_fields: :environment do
		log = ActiveSupport::Logger.new('log/populate_bldg_counts.log')
		start_time = Time.now

		Building.all.each do |bldg|
			puts "Updating building [#{bldg.id}]"
      bldg.update_total_unit_count
      bldg.update_active_unit_count

      unarchived_units = bldg.units.unarchived
			if unarchived_units.count > 0
				bldg.update_attributes(last_unit_updated_at: unarchived_units.first.updated_at)
			end
		end

		Landlord.all.each do |ll|
			puts "Updating landlord [#{ll.id}]"
			ll.update_total_unit_count
      ll.update_active_unit_count

      bldgs = ll.buildings.joins(:units).order('updated_at DESC')
      unarchived_bldgs = bldgs.unarchived
      if unarchived_bldgs.count > 0
      	ll.update_attributes(last_unit_updated_at: unarchived_bldgs.first.updated_at)
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
