namespace :maintenance do
	desc 'copy over listing IDs from Nestio'
	task match_listing_ids: :environment do
		log = ActiveSupport::Logger.new('log/match_listing_ids.log')
		start_time = Time.now

		mechanize = Mechanize.new
		mechanize.user_agent_alias = "Mac Safari"
		mechanize.follow_meta_refresh = true

		def mark_done(log, start_time, skipped)
			puts "Done!\n"
  		log.info "Done!\n"
  		puts "These listings not processed:\n"
		  puts skipped.join("\n")
		  log.info "These listings not processed:\n"
		  log.info skipped.join("\n")
  		end_time = Time.now
	    duration = (start_time - end_time) / 1.minute
	    log.info "Task finished at #{end_time} and last #{duration} minutes."
	    log.close
		end

		# make into commandline args
		company = Company.find_by(name: 'MyspaceNYC')
		# begin pulling down new data
		nestio_url = "https://nestiolistings.com/api/v1/public/listings?key=#{ENV['NESTIO_KEY']}"		
		total_pages = 99
	  page = 1
	  page_count_limit = 50

		puts "Pulling Nestio data for all listings...";
		log.info "Pulling Nestio data for all listings...";

	  done = false
	  skipped = []
	  for j in 1..total_pages
	  	if done
	  		mark_done(log, start_time, skipped)
	  		break
	  	end

	  	# try not to exceed google's rate limit
	  	puts "Page #{j} ----------------------------"
	  	log.info "Page #{j} ----------------------------"

	  	page = mechanize.get("#{nestio_url}&page=#{j}")
	  	json_data = JSON.parse page.body
	  	
	    total_pages = json_data['total_pages']
	    page = json_data['page']
	    total_items = json_data['total_items']
	    items = json_data['items']

	    for i in 0..page_count_limit-1
	      count = (page-1) * page_count_limit + i
	      if count >= json_data['total_items']
	        done = true
	        break
	      end

	      item = items[i]

	      # we only want residential properties
	      # if item['property_type'] != 'residential'
	      # 	next
	      # end

	      addr = item['building']['street_address'].gsub("\n", ' ').squeeze(' ').strip

	      puts "[#{i}] #{addr} #{item['unit_number']}"
	      log.info "[#{i}] #{addr} #{item['unit_number']}"

				unit = Unit.joins(:building)
					.where(building_unit: item['unit_number'])
					.where("buildings.company_id = ?", company.id)
					.where("buildings.formatted_street_address ILIKE ?", "%#{addr}%")
					.first

				if unit
					puts "- updating unit listing ID to #{item['id']}"
					unit.update({listing_id: item['id']})
					unit.save!
				else
					puts "- NOT FOUND"
					skipped << addr
				end			
	    end
	  end

	  if !done
		  mark_done(log, start_time)
		end

	end
end