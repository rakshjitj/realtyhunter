namespace :maintenance do
	desc "clean up to match latest schema changes"
	task :change_public_url_sales_listing => :environment do
		log = ActiveSupport::Logger.new('log/change_public_url_sales_listing.log')
		start_time = Time.now

		puts "Changing public url..."
		log.info "Changing public url..."

		@listings = SalesListing.all
		@listings.each {|listing|
			#if u.name != 'Blank Slate'
				url = "https://myspacenyc.com/sales-details/?sid=#{listing.unit.id}"
				puts "listing public url Start update #{listing.unit.id}"
				listing.unit.update!(public_url: url)
				puts "listing public url End update #{listing.unit.id}"
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
