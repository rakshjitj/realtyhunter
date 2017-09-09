namespace :maintenance do
	desc 'update units public url with new URL from Nestio'
	task nestio_match_listings: :environment do
		log = ActiveSupport::Logger.new('log/nestio_match_listings.log')
		start_time = Time.now

		mechanize = Mechanize.new
		mechanize.user_agent_alias = "Mac Safari"
		mechanize.add_auth('https://nestiolistings.com/api/v2/sync/listings/?listing_type=rentals&listing_type=sales', '65c4bf89794a410aac9ba57eda1e78b1', '')
		mechanize.follow_meta_refresh = true

		def number_or_nil(string)
		  num = string.to_i
		  num if num.to_s == string
		end

		def mark_done(log, start_time)
			puts "Done!\n"
  		log.info "Done!\n"
  		end_time = Time.now
	    duration = (start_time - end_time) / 1.minute
	    log.info "Task finished at #{end_time} and last #{duration} minutes."
	    log.close
		end

		nestio_url = "https://nestiolistings.com/api/v2/sync/listings/?listing_type=rentals&listing_type=sales"

	  next_page_ptr = nil
		puts "Pulling Nestio data for all listings...";
		log.info "Pulling Nestio data for all listings...";

		page = mechanize.get("#{nestio_url}")
  	has_more_data = true
  	while has_more_data do
  		json_data = JSON.parse page.body
	  	items = json_data['items']

	    for i in 0..items.count-1
	      item = items[i]
	      listing_id = item['description'][/MyspaceNYCListingID.*/].split(":")[1].strip.to_i
				unit = Unit.where(listing_id: listing_id).first
				nestio_id = item['id']
				public_url = "http://www.myspace-nyc.com/listings/#{nestio_id}/"
				# if !unit
					# puts "Missing unit - Listing id [#{listing_id}] nestio id: [#{nestio_id}]"
				# end

				if unit && (unit.public_url != public_url)
					puts "[#{i}] #{item['building']['street_address']} #{item['unit_number']} - updating unit"
	      	log.info "[#{i}] #{item['building']['street_address']} #{item['unit_number']} - updating unit"
					unit.update_columns(public_url: public_url)
				end
	    end

	    next_page_ptr = json_data['pointer']['next_id']
	  	has_more_data = !next_page_ptr.nil?
  		puts "PAGE #{next_page_ptr}"
  		page = mechanize.get("#{nestio_url}&max_id=#{next_page_ptr}")
		end

		 mark_done(log, start_time)
	end
end
