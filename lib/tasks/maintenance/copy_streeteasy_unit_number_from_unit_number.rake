namespace :maintenance do
	desc "clean up to match latest schema changes"
	task :copy_streeteasy_unit_number_from_unit_number => :environment do
		log = ActiveSupport::Logger.new('log/copy_streeteasy_unit_number_from_unit_number.log')
		start_time = Time.now

		puts "copy_streeteasy_unit_number_from_unit_number..."
		log.info "copy_streeteasy_unit_number_from_unit_number..."

		@units = Unit.all
		@units.each do |unit|
			unit.update(streeteasy_unit: unit.building_unit)
		end

		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end