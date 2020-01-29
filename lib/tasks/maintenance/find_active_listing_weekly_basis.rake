namespace :maintenance do
	desc "clean up to match latest schema changes"
	task :find_active_listing_weekly_basis => :environment do
		log = ActiveSupport::Logger.new('log/find_active_listing_weekly_basis.log')
		start_time = Time.now

		puts "add open houses daily basis..."
		log.info "add open houses daily basis..."

		@listing_find = []
	    @all_updated_listings = []
	    @new_listings = ResidentialListing.where("created_at >= ?", Time.now.at_beginning_of_week)
	    @updated_units = Unit.where("updated_at >= ? AND status =?", Time.now.at_beginning_of_week, 0)
	    @updated_units.each do |update_unit|
	      if update_unit.residential_listing
	        @listing_find << update_unit.residential_listing.id 
	      end
	    end
	    @updated_lsitings = ResidentialListing.where("updated_at >= ?", Time.now.at_beginning_of_week)
	    @updated_lsitings.each do |update_lsiting|
	      if update_lsiting.unit.status == 0
	        @listing_find << update_lsiting.id
	      end
	    end
	    @listing_find = @listing_find.uniq
	    @listing_find.each do |listing|
	      listing = ResidentialListing.find(listing)
	      listing.unit.audits.each do |p|
	        a = (Time.now.at_beginning_of_week .. Time.now.at_end_of_week).include?(p.created_at)
	        if a == true
	          if p.audited_changes.to_a[0][0] == "status"
	            if p.audited_changes.to_a[0][1][1] == "active"
	              @all_updated_listings << listing
	            end
	          end
	        end
	      end
	    end

	    r =ListingDetail.create(a: Time.now.at_beginning_of_week, b: @new_listings.count, c: @all_updated_listings.count)
	    r.save!
		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end
