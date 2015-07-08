namespace :import do
	desc 'Import residential unit data from Nestio into our database'
	task residential: :environment do
		log = ActiveSupport::Logger.new('log/import_residential.log')
		start_time = Time.now

		mechanize = Mechanize.new
		mechanize.user_agent_alias = "Mac Safari"
		mechanize.follow_meta_refresh = true

		def number_or_nil(string)
		  num = string.to_i
		  num if num.to_s == string
		end

		def add_building(mechanize, bldg, company, landlord, log)
			nestio_address = "#{bldg['street_address']}, #{bldg['city']}, #{bldg['state']} #{bldg['zipcode']}"
			page = mechanize.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{nestio_address}&key=#{ENV['GOOGLE_MAPS_KEY']}")
			google_results = JSON.parse page.body
			result = google_results['results'][0]

			route = nil
			street_number = nil
			country_short = nil
			postal_code = nil
			administrative_area_level_1_short = nil
			administrative_area_level_1_long = nil
			#administrative_area_level_2_short = nil
			sublocality = nil
			neighborhood_name = nil

			#puts "#{result['address_components']}"
			#puts "BLDG: #{bldg}"
			#puts "COMP: #{google_results}"

			result['address_components'].each{|c| 
				#puts "#{c['types']}"
				if c['types'].include? 'route'
					route = c['short_name']
				elsif c['types'].include? 'street_number'
					street_number = c['short_name']
				elsif c['types'].include? 'country'
					country_short = c['short_name']
				elsif c['types'].include? 'postal_code'
					postal_code = c['short_name']
				elsif c['types'].include? 'administrative_area_level_1'
					administrative_area_level_1_short = c['short_name']
					administrative_area_level_1_long = c['long_name']
				#elsif c['types'].include? 'administrative_area_level_1'
					#administrative_area_level_2_short = c['short_name']
				elsif c['types'].include? 'sublocality'
					sublocality = c['short_name']
				elsif c['types'].include? 'neighborhood'
					neighborhood_name = c['short_name']
				end
			}

			if !neighborhood_name || neighborhood_name.empty?
				neighborhood_name = bldg['neighborhood']['name']
			end
			if !sublocality || sublocality.empty?
				sublocality = bldg['neighborhood']['area']
			end

			nabe = Neighborhood.find_by(name: neighborhood_name)
			if !nabe && (neighborhood_name && !neighborhood_name.empty?)
				nabe = Neighborhood.create!({
					name: neighborhood_name,
					borough: sublocality,
					city: administrative_area_level_1_long,
					state: administrative_area_level_1_short
				})
			end

			req_sec = RequiredSecurity.where(company: company).first

			record = Building.find_by(formatted_street_address: result['formatted_address'])
			if !record
				puts "#{result['formatted_address']} - added"
				log.info "#{result['formatted_address']} - added"
				record = Building.create!({
					lat: result['geometry']['location']['lat'],
					lng: result['geometry']['location']['lng'],
					route: route,
					street_number: street_number,
					country_short: country_short,
					postal_code: postal_code,
					administrative_area_level_1_short: administrative_area_level_1_short,
					administrative_area_level_2_short: administrative_area_level_1_long,
					sublocality: sublocality,
					formatted_street_address: result['formatted_address'],
					place_id: result['place_id'],
					landlord: landlord,
					neighborhood: nabe,
					notes: bldg['building_description'] || nil,
					company: company,
					required_security: req_sec
				})
			end
			
			amenities = []
			bldg['amenities'].each{ |a| 
				amenity_name = a.downcase.strip
				#puts "\n\n\n CHECKING #{amenity_name}"
				amenity = BuildingAmenity.find_by(name: amenity_name, company: company)
				if !amenity
					#puts "*** Adding REQUIRED SECURITY #{amenity_name}"
					amenity = BuildingAmenity.create!(company: company, name: a.titleize)
				end
				amenities << amenity
				record.building_amenities << amenity
			}

			
			# TODO: required_security, rental_terms
			#puts "AMENITIES: #{amenities.uniq}"
			record
		end

		def mark_done(log, start_time)
			puts "Done!\n"
  		log.info "Done!\n"
  		end_time = Time.now
	    duration = (start_time - end_time) / 1.minute
	    log.info "Task finished at #{end_time} and last #{duration} minutes."
	    log.close
		end


		# make into commandline args
		company = Company.find_by(name: 'MyspaceNYC')
		default_landlord = Landlord.find_by(name: 'Unassigned')
	  default_office = Office.find_by(name: 'Crown Heights')
	  default_password = "lorimer713"

		api_key = "7abe027d49624988b64c22acb9f196c5"
		nestio_url = "https://nestiolistings.com/api/v1/public/listings?key=#{api_key}"

		# clear old data
		Neighborhood.delete_all
		Building.delete_all
		ResidentialUnit.delete_all

		# begin pulling down new data
		total_pages = 99
	  page = 1
	  page_count_limit = 50

		puts "Pulling Nestio data for all listings...";
		log.info "Pulling Nestio data for all listings...";

		#titles = []
		#renter_fees = []
		#statii = []

	  done = false
	  for j in 1..total_pages
	  	if done
	  		mark_done(log, start_time)
	  		break
	  	end

	  	# try not to exceed google's rate limit
	  	sleep(10)
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
	      if item['property_type'] != 'residential'
	      	next
	      end

	      puts "[#{i}] #{item['building']['street_address']} #{item['unit_number']}"
	      log.info "[#{i}] #{item['building']['street_address']} #{item['unit_number']}"
	      bldg_data = item['building']
	      building = add_building(mechanize, bldg_data, company, default_landlord, log)

	      amenities = []
	      
				item['unit_amenities'].each{ |a| 
					amenity_name = a.downcase.strip
					amenity = ResidentialAmenity.find_by(name: amenity_name)
					if !amenity
						amenity = ResidentialAmenity.create!(company: company, name: amenity_name)
					end
					#amenities << amenity
					#titles << amenity_name
				}

				open_house = nil
				item['open_houses'].each {|h| 
					open_house = "" if open_house == nil
					open_house = open_house + "Date: #{h['date']} From: #{h['start_time']} To: #{h['end_time']}"
				}
				
				beds = "0"
				case item['layout'].downcase
				when 'studio'
					beds = 0
				when '1 bedroom'
					beds = 1
				when '2 bedroom'
					beds = 2
				when '3 bedroom'
					beds = 3
				when '4+ bedroom'
					beds = 4
				when 'loft'
					beds = 0
				end

				status = 'off'
				#puts "#{item['status']}"
				case item['status'].downcase
				when 'available'
					status = 'active'
				when 'app pending'
					status = 'pending'
				when 'lease out'
					status = 'off'
				end
				#statii << item['status']

				lease_duration = '1 Year'
				if item['min_lease_term']
					lease_duration = item['min_lease_term']
				end
				if !item['min_lease_term'] && item['max_lease_term']
					lease_duration = item['max_lease_term']
				end

				description = "#{item['unit_description']}"
				if item['occupancy_status']
					description = description + "\n\nOccupancy Status: #{item['occupancy_status']}\n"
				end
				if item['furnished_type']
					description = description + "Furnished Type: #{item['furnished_type']}\n"
				end

				op_fee_percentage = nil
				tp_fee_percentage = nil
				# text here varies, but often looks something like "Owner pays 100%"
				# if we can make sense of the text, try to.
				if item['incentives'] && !item['incentives'].empty?
					incentive = item['incentives'].downcase.strip
					percent_sign_idx = item['incentives'].index('%')
					if percent_sign_idx
						puts "\n before:incentives [#{incentive}]"
						if incentive.include? "owner pays " 
							text_length = "owner pays ".length
							number_length = percent_sign_idx - text_length
							op_fee_percentage = number_or_nil(incentive[text_length, number_length])
						elsif incentive.include? "ownerpays "
							text_length = "owner pays ".length
							number_length = percent_sign_idx - text_length
							op_fee_percentage = number_or_nil(incentive[text_length, number_length])
						elsif incentive.include? "tenant pays "
							text_length = "tenant pays ".length
							number_length = percent_sign_idx - text_length
							tp_fee_percentage = number_or_nil(incentive[text_length, number_length])
						end
					end

					
				end
				puts "\n incentive:[#{incentive}] TP:[#{tp_fee_percentage}] OP:[#{op_fee_percentage}]"
				log.info "\n incentive:[#{incentive}] TP:[#{tp_fee_percentage}] OP:[#{op_fee_percentage}]"
				
				#access_info: 
				#agents

				#ResidentialUnit.find_by()
				unit = ResidentialUnit.create!({
					building_unit: item['unit_number'],
					rent: item['rent'].to_i,
					available_by: item['date_available'],
					status: status,
					open_house: open_house,
					building: building,
					beds: beds,
					baths: item['bathrooms'],
					notes: description,
					lease_duration: lease_duration,
					listing_id: item['id'],
					op_fee_percentage: op_fee_percentage,
					tp_fee_percentage: tp_fee_percentage,
				})

				if item['pets'] && !unit.building.pet_policy
					policy_name = item['pets'].downcase.strip
	      	pet_policy = PetPolicy.find_by(name: policy_name, company: company)
					if !pet_policy
						#puts "*** Adding PET POLICY [policy_name]"
						pet_policy = PetPolicy.create!({
							name: policy_name,
							company: company
						})
					end
					unit.building.pet_policy = pet_policy
				end

				# item['photos'].each{ |p| 
				# 	image = Image.new
	   #      image.file = URI.parse(p['original'])
	   #      image.save
				# 	unit.images << image
		  #   }

	    end
	  end

	  #puts "AMENITIES: #{titles.uniq}"
	  #puts "RENTER FEES: #{renter_fees.uniq}"
	  #puts "STATII #{statii.uniq}"
	  if !done
		  mark_done(log, start_time)
		end
	end
end