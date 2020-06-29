namespace :maintenance do
	desc "clean up to match latest schema changes"
	task :inactive_units_alert => :environment do
		log = ActiveSupport::Logger.new('log/inactive_units_alert.log')
		start_time = Time.now

		puts "Inactive Unit Alert..."
		log.info "Inactive Unit Alert..."

		#@res_list =	ResidentialListing.joins(:unit).where("residential_listings.streeteasy_flag =? and units.status =? and units.archived =?", true, 0, false)
		inactive_units = ResidentialListing.joins(unit: {building: [:company, :landlord]}).where("units.archived =? and units.status =? and landlords.ll_importance =? and residential_listings.updated_at <= ?", false, 0, "gold", 15.days.ago).each.map{|rental| "\n *Inactive* *Units* *Alert* \n #{rental.unit.building.street_number} #{rental.unit.building.route} ##{rental.unit.building_unit} \n #{rental.unit.rent} \n #{rental.beds} | #{rental.baths} \n LLC: #{rental.unit.building.landlord.code} \n POC: #{User.find(rental.unit.building.point_of_contact).name}"}.join(" ")
		client = Slack::Web::Client.new
    	client.auth_test
    	client.chat_postMessage(channel: '#am_alerts', text: inactive_units, as_user: false)
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
