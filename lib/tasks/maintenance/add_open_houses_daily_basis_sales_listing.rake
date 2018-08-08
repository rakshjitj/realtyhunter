namespace :maintenance do
	desc "clean up to match latest schema changes"
	task :add_open_houses_daily_basis_sales_listing => :environment do
		log = ActiveSupport::Logger.new('log/add_open_houses_daily_basis_sales_listing.log')
		start_time = Time.now

		puts "add open houses daily basis..."
		log.info "add open houses daily basis..."

		@open_houses = SalesListing.joins(:unit).where("streeteasy_flag =? AND archived =?", true,false)
		@open_houses.each do |open_house|
			unit_id = open_house.unit.id
			day = 4.days.from_now.strftime("%Y-%m-%d")
			start_time = Time.strptime("10:00:00", "%H:%M:%S")
			end_time = Time.strptime("13:00:00", "%H:%M:%S")
			#OpenHouse.create(day: day, start_time: start_time, end_time: end_time, unit_id: unit_id)
			open_house = OpenHouse.create!(day: day, start_time: start_time, end_time: end_time, unit_id: unit_id)
		end

		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end