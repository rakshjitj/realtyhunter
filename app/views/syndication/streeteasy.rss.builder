# todo: before re-enabling caching here, need to figure out how to expire the cache here
# when a building photo is updated. the building photo is displayed before listings photos,
# but adding/removing building photos does not update the listing object.
#cache "streeteasy/#{@listings.ids.join('')}-#{@listings.ids.count}-#{@listings.maximum(:updated_at).to_i}" do

# url looks like <base_url>/syndication/1/streeteasy
xml.instruct! :xml, :version => "1.0"
xml.streeteasy :version => "1.6" do
  xml.properties do

	  @listings.each do |listing|

	  	# NOTE: this is super hacky. We should filter this out before sending
	  	# to the view.
	  	if !@primary_agents[listing.unit_id].blank? &&
	  				@primary_agents[listing.unit_id][0].name == @company.name
	  		# skip our generic catch-all account
	  		next
	  	end

			if listing.status == "active"
				@status = "active"
			elsif listing.status == "pending"
				@status = "in-contract"
			# elsif listing.status == "off"
			# 	@status == "rented"
			end

			# listing type
			if listing.r_id
				@ptype = "rental"
			# else sales
			# @ptype = "sale"
			end

			xml.property type: @ptype, status: @status, id: listing.listing_id, url: listing.public_url do
				xml.location do
					# note we don't want to give out the building number for rentals!
					xml.address listing.street_number + " " + listing.route
					xml.apartment listing.building_unit
					xml.city listing.sublocality
					xml.state listing.administrative_area_level_1_short
					xml.zipcode listing.postal_code
					xml.neighborhood listing.neighborhood_name
				end

				xml.details do
					xml.price listing.rent

				 	if !listing.has_fee
				 		xml.noFee
				 	end

					if listing.exclusive
						xml.exclusive
					end

					if !listing.r_beds.nil?
						xml.bedrooms listing.r_beds.to_i
					elsif !listing.s_beds.nil?
						xml.bedrooms listing.s_beds.to_i
					end

					if !listing.r_total_room_count?
						xml.totalrooms listing.r_total_room_count.to_i
					end

					baths = nil
					if !listing.r_baths.nil?
						baths = listing.r_baths
					elsif !listing.s_baths.nil?
						baths = listing.s_baths
					end

					if baths
						xml.bathrooms baths.floor.to_i
						decimal_idx = baths.to_s.index('.5')
						if !decimal_idx.nil?
							xml.half_baths 1
						end
					end

					xml.availableOn listing.available_by # rentals only

					if listing.r_id
						xml.description h raw sanitize listing.description,
		        		tags: %w(h1 h2 h3 h4 h5 h6 p i b strong em a ol ul li q blockquote font span br div)
		      elsif listing.s_id
		        xml.description h raw sanitize listing.public_description,
		        		tags: %w(h1 h2 h3 h4 h5 h6 p i b strong em a ol ul li q blockquote font span br div)
					end

					xml.propertyType "rental"

					# streeteasy has their own approved list of amenities
					# doorman, gym, pool, elevator, garage, parking, balcony, storage, patio, fireplace
					# washerDryer, dishwasher, furnished, pets, other
					xml.amenities do

						@other_amenities = []
						attribute_found = {}
						if @building_amenities[listing.building_id]
							@building_amenities[listing.building_id].map{|b| b.name}.each do |bm|
								case bm
									when "doorman"
										xml.doorman
									when "gym", "fitness center", "sauna"
										if !attribute_found["gym"]
											attribute_found["gym"] = 1
											xml.gym
										end
									when "pool"
										xml.pool
									when "elevator"
										xml.elevator
									when "garage parking"
										xml.garage
									when "parking", "parking for $200 a month"
										if !attribute_found["parking"]
											attribute_found["parking"] = 1
											xml.parking
										end
									when "balcony"
										xml.balcony
									when "storage"
										xml.storage
									when "courtyard", "shared yard for building"
										if !attribute_found["patio"]
											attribute_found["patio"] = 1
											xml.patio # outdoor space ?
										end
									when "fireplace"
										xml.fireplace
									when "laundry in building"
										if !attribute_found["washerDryer"]
											attribute_found["washerDryer"] = 1
											xml.washerDryer
										end
										@laundry_included = true
									when "case by case",  "cats only", "cats/small dogs", "dogs only", "monthly pet fee" ,
											"pet deposit required", "pets allowed", "pets ok", "pets upon approval", "small pets ok (<30lbs)"
										xml.pets
									else
										@other_amenities << bm
								end # case
							end
						end

						pets_allowed = ["case by case",  "cats only", "cats/small dogs", "dogs only", "monthly pet fee" ,
								"pet deposit required", "pets allowed", "pets ok", "pets upon approval", "small pets ok (<30lbs)"]
						if @pet_policies[listing.building_id] && pets_allowed.include?(@pet_policies[listing.building_id][0].pet_policy_name)
							xml.pets
						end

						if @residential_amenities && @residential_amenities[listing.unit_id]
							@residential_amenities[listing.unit_id].map{|a| a.name}.each do |rm|

								case rm
									when "balcony/terrace"
										xml.balcony
									when "storage", "basement"
										xml.storage
									when "private yard", "shared yard"
										xml.patio # outdoor space ?
									when "washer/dryer hookups", "washer/dryer in unit"
										if !attribute_found["washerDryer"]
											attribute_found["washerDryer"] = 1
											xml.washerDryer
										end
									when "dishwasher"
										xml.dishwasher
									when "furnished"
										xml.furnished
									else
										if !attribute_found[rm]
											attribute_found[rm] = 1
											@other_amenities << rm
										end
								end # case

							end
						end

						if !@other_amenities.blank?
							xml.other @other_amenities.join(", ")
						end

					end # amenities
				end # details

				if !@open_houses[listing.unit_id].blank?
					xml.openHouses do
						@open_houses[listing.unit_id].each do |oh|
							xml.openHouse do
								# must match this format: 2006-11-20 3:30pm
								xml.startsAt oh.day.strftime("%Y-%m-%d") + " " + oh.start_time.strftime("%I:%M%p")
								xml.endsAt oh.day.strftime("%Y-%m-%d") + " " + oh.end_time.strftime("%I:%M%p")
								xml.apptOnly
							end
						end
					end
				end

				if !@primary_agents[listing.unit_id].blank?
					xml.agents do
						@primary_agents[listing.unit_id].each do |agent|
							xml.agent id: agent.id do
								xml.name agent.name
								xml.company @company.name
								if @agent_images[agent.id]
									xml.photo url:@agent_images[agent.id].file.url(:large)
								end
							  xml.url agent.public_url
						  	xml.email agent.email
						  	xml.lead_email agent.email
						  	xml.phone_numbers do
						  		xml.main agent.mobile_phone_number
						  		xml.office agent.office_telephone
						  		xml.cell agent.mobile_phone_number
						  		xml.fax agent.office_fax
						  	end
						  end
						end
					end
				end

				xml.media do
					if @bldg_images[listing.building_id]
						@bldg_images[listing.building_id].each do |i|
							xml.photo url:i.file.url(:large), position: i.priority, description:""
						end
					end
					if @images[listing.unit_id]
						@images[listing.unit_id].each do |i|
							xml.photo url:i.file.url(:large), position: i.priority, description:""
						end
					end
				end

			end # property
		end # listings.each
	end # properties
end #streeteasy
#end # cache
