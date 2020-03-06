namespace :maintenance do
	desc "clean up to match latest schema changes"
	task :find_active_listing_weekly_basis => :environment do
		log = ActiveSupport::Logger.new('log/find_active_listing_weekly_basis.log')
		start_time = Time.now

		puts "find active listings on weekly basis..."
		log.info "find active listings on weekly basis..."

		@listing_find = []
	    @all_updated_listings = []
	    @new_listings = ResidentialListing.where("created_at >= ?", Time.now.at_beginning_of_week)
	    #@new_listings = ResidentialListing.where(:created_at => Time.now.at_beginning_of_week..Time.now.at_end_of_week)
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
	    @new_listings.each do |new_listing|
	    	address = new_listing.unit.building.formatted_street_address
	    	if !new_listing.unit.building_unit.nil?
	    		unit = new_listing.unit.building_unit
	    	else
	    		unit = "---"
	    	end
	    	if !new_listing.unit.streeteasy_unit.nil?
	    		se_unit = new_listing.unit.streeteasy_unit
	    	else
	    		se_unit = "---"
	    	end
	    	if !new_listing.unit.building.point_of_contact.nil?
	    		poc = User.find(new_listing.unit.building.point_of_contact).name
	    	else
	    		poc = "---"
	    	end
	    	if new_listing.unit.building.landlord
	    		llc = new_listing.unit.building.landlord.code
	    	else
	    		llc = "---"
	    	end
	    	if !new_listing.unit.rent.nil?
	    		price = new_listing.unit.rent
	    	else
	    		price = "$0"
	    	end
	    	ListingDetailDownload.create(address: address, unit: unit, se_unit: se_unit, poc: poc, llc: llc, price: price, listing_detail_id: r.id, listing_label: "new")
	    end

	    @all_updated_listings.each do |all_update_listing|
			address = all_update_listing.unit.building.formatted_street_address
	    	if !all_update_listing.unit.building_unit.nil?
	    		unit = all_update_listing.unit.building_unit
	    	else
	    		unit = "---"
	    	end
	    	if !all_update_listing.unit.streeteasy_unit.nil?
	    		se_unit = all_update_listing.unit.streeteasy_unit
	    	else
	    		se_unit = "---"
	    	end
	    	if !all_update_listing.unit.building.point_of_contact.nil?
	    		poc = User.find(all_update_listing.unit.building.point_of_contact).name
	    	else
	    		poc = "---"
	    	end
	    	if all_update_listing.unit.building.landlord
	    		llc = all_update_listing.unit.building.landlord.code
	    	else
	    		llc = "---"
	    	end
	    	if !all_update_listing.unit.rent.nil?
	    		price = all_update_listing.unit.rent
	    	else
	    		price = "$0"
	    	end
	    	ListingDetailDownload.create(address: address, unit: unit, se_unit: se_unit, poc: poc, llc: llc, price: price, listing_detail_id: r.id, listing_label: "reactivated")	    	
	    end
		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end
