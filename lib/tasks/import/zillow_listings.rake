namespace :import do
	desc 'Import residential unit data from Nestio into our database'
	task zillow_listings: :environment do

		require 'csv'
		log = ActiveSupport::Logger.new('log/import_zillow_listings.log')
		start_time = Time.now

		mechanize = Mechanize.new
		mechanize.user_agent_alias = "Mac Safari"
		mechanize.follow_meta_refresh = true

		def number_or_nil(string)
		  num = string.to_i
		  num if num.to_s == string
		end


		def add_building(mechanize, row, company, landlord, log)
			number = row[1]
      street = row[2]
      city = row[3]
      state = row[4]
      zipcode = row[5]

      puts "\n\nROW: #{row.inspect}"
			nestio_address = "#{number} #{street}, #{city}, #{state} #{zipcode}"
			puts "NESTIO ADDRESS #{nestio_address}"

			puts "\nhttps://maps.googleapis.com/maps/api/geocode/json?address=#{nestio_address}&key=#{ENV['GOOGLE_MAPS_KEY']}"
			page = mechanize.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{nestio_address}&key=#{ENV['GOOGLE_MAPS_KEY']}")
			google_results = JSON.parse page.body
			result = google_results['results'][0]
			puts "GOOGLE RESULT #{result.inspect}"
			route = nil
			street_number = nil
			country_short = nil
			postal_code = nil
			administrative_area_level_1_short = nil
			administrative_area_level_1_long = nil
			#administrative_area_level_2_short = nil
			sublocality = nil
			neighborhood_name = nil

			#puts "HELLO #{result.inspect}"
			#puts "BLDG: #{bldg}"
 			puts "COMP: #{google_results}"
			if !result 
				puts "Could not get location info. Skipping..."
				#return nil
			end

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

			nabe = Neighborhood.find_by(name: neighborhood_name)
			if !nabe && (neighborhood_name && !neighborhood_name.empty?)
				nabe = Neighborhood.create!({
					name: neighborhood_name,
					borough: sublocality,
					city: administrative_area_level_1_long,
					state: administrative_area_level_1_short
				})
			end

			#if !postal_code
				#puts "Nil postal_code returned by google. Not creating this building."
				#return nil
			#end

			record = Building.find_by(formatted_street_address: result['formatted_address'])
			if !record
				puts "- building added"
				log.info "- building added"
				record = Building.create!({
					lat: result['geometry']['location']['lat'],
					lng: result['geometry']['location']['lng'],
					route: route,
					street_number: street_number,
					country_short: country_short,
					postal_code: zipcode, # use our zipcode, in case google doesn't return one
					administrative_area_level_1_short: administrative_area_level_1_short,
					administrative_area_level_2_short: administrative_area_level_1_long,
					sublocality: sublocality,
					formatted_street_address: result['formatted_address'],
					place_id: result['place_id'],
					landlord: landlord,
					neighborhood: nabe,
					company: company,
				})
			end

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
		default_office = Office.find_by(name: 'Crown Heights')
	  default_password = "lorimer713"

		# clear any old cache laying around, as delete_all will not trigger our 
		# after_destroy callbacks
		#Rails.cache.clear
		# clear old data
		#Building.delete_all
		#ResidentialUnit.delete_all

		puts "Getting data for all zillow listings..."
		log.info "Getting data for all zillow listings..."
		count = 0
		CSV.foreach('lib/tasks/import/zillow_listings.csv', col_sep: ';') { |row| 

			# skip headers
			if count == 0
				count = count + 1
				next
			end

			# skip what we've already added
			if count < 4939
				count = count + 1
				next
			end

      number = row[1]
      street = row[2]
      city = row[3]
      state = row[4]
      zip = row[5]
      unit_number = row[6]
      rent = row[7].to_i
      beds = row[8].to_i
      baths = row[9].to_f
      date_available = row[10]
      notes = row[11].strip
      landlord_name = row[12]
      features_and_terms = row[13].strip
      # hoods - not copying over
      # parking_spaces - not copying over
      landlord_fee = row[16].strip
      lease_ends_on = row[17]
      access = row[18]

      if rent == nil || rent < 1
      	rent = 1
      end

      if beds == nil || beds > 11
      	beds = 0
      end

      if baths == nil || baths > 11
      	baths = 0
      end

      if !unit_number || unit_number.empty?
      	unit_number = 'NOT FOUND'
      end

      puts "[#{count}] #{number} #{street} Rent: #{rent}"
      log.info "[#{count}] #{number} #{street} #{unit_number}"

      landlord = Landlord.find_by(name: landlord_name)
      if !landlord
      	landlord = Landlord.find_or_create_by(name: "Unassigned")
      end
      building = add_building(mechanize, row, company, landlord, log)
      if building
				unit = ResidentialUnit.create!({
					building_unit: unit_number,
					rent: rent,
					available_by: date_available,
					status: 'off',
					building: building,
					beds: beds,
					baths: baths,
					notes: notes + "\n\n" + features_and_terms + "\n\n" + landlord_fee,
					lease_start: "12",
					lease_end: "12"
				})
			else
				puts " - no building, so skipping this listing."
			end

			# don't exceed google's rate limit
			if count % 10 == 0 && count > 0
				sleep(10)
			end

			count = count + 1
		}

		mark_done(log, start_time)

	end
end