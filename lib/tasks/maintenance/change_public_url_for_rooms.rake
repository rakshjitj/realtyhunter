namespace :maintenance do
	desc "clean up to match latest schema changes"
	task :change_public_url_for_rooms => :environment do
		log = ActiveSupport::Logger.new('log/change_public_url_for_rooms.log')
		start_time = Time.now

		puts "Changing public url for rooms..."
		log.info "Changing public url for rooms..."

		@listings = ResidentialListing.where(roomshare_department: true)
		
		@listings.each {|listing|
			#if u.name != 'Blank Slate'
				url = "https://myspacenyc.com/rentals-room-details/?rid=#{listing.unit.id}"
				listing.unit.update!(public_url_for_room: url)
			#end
		}

		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end