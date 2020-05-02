namespace :maintenance do
	desc "clean up to match latest schema changes"
	task :active_on_renthop_same_as_streeteasy => :environment do
		log = ActiveSupport::Logger.new('log/active_on_renthop_same_as_streeteasy.log')
		start_time = Time.now

		puts "Changing renthop..."
		log.info "Changing renthop..."

		@res_list =	ResidentialListing.joins(:unit).where("residential_listings.streeteasy_flag =? and units.status =? and units.archived =?", true, 0, false)
		@res_list.each do |listing|
			listing.update!(renthop: true)
		end
		# @listings = SalesListing.all
		# @listings.each {|listing|
		# 	#if u.name != 'Blank Slate'
		# 		url = "https://myspacenyc.com/sales-details/?sid=#{listing.unit.id}"
		# 		puts "listing public url Start update #{listing.unit.id}"
		# 		listing.unit.update!(public_url: url)
		# 		puts "listing public url End update #{listing.unit.id}"
		# 	#end
		# }

		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end
