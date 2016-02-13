xml.instruct! :xml, :version => "1.0"
xml.streeteasy :version => "1.6" do
  xml.properties do

	  @listings.each do |listing|

	  	# NOTE: this is super hacky. We should filter this out before sending
	  	# to the view.
	  	if @primary_agents[listing.unit_id].length &&
	  				@primary_agents[listing.unit_id][0].name == @company.name
	  		# skip our generic catch-all account
	  		next
	  	end

	  	# translate status
	  	@status = 'active'
			if listing.status == "active"
				@status = "active"
			elsif listing.status == "pending"
				@status = "off-market"
			elsif listing.status == "offer_submitted"
				@status = "contract-out"
			elsif listing.status == "offer_accepted"
				@status = "in-contract"
		  elsif listing.status == "binder_signed"
				@status = "contract-signed"
			elsif listing.status == "off" ||
				listing.status == "rented"
			end

			# listing type
			if listing.r_id
				@ptype = "rental"
			elsif listing.c_id
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

					xml.bedrooms listing.beds
					xml.bathrooms listing.baths
					xml.availableOn listing.available_by # rentals only

					if listing.r_id
            xml.description h raw sanitize listing.description, tags: %w()
					elsif listing.c_id
						xml.description h raw sanitize listing.property_description, tags: %w()
					end

					xml.propertyType "rental"

					# 	if @pet_policies[listing.building_id]
					# 		xml.pets @pet_policies[listing.building_id][0].pet_policy_name
					# 	else
					# 		xml.pets nil
					# 	end

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
									when "pets allowed", "cats only"
										xml.pets
									# pets TODO
									else
										@other_amenities << bm
								end # case
							end
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

						if !@other_amenities.empty?
							xml.other @other_amenities.join(", ")
						end

					end # amenities
				end # details

				# TODO: open houses

				if !@primary_agents[listing.unit_id].empty?
					xml.agents do
						@primary_agents[listing.unit_id].each do |agent|
							xml.agent id: agent.id do
								xml.name agent.name
								xml.company @company.name
								if @agent_images[agent.id]
									xml.photo url:@agent_images[agent.id].file.url(:original)
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
					if @images[listing.unit_id]
						@images[listing.unit_id].each do |i|
							xml.photo url:i.file.url(:original), position: i.priority, desription:""
						end
					end
				end

			end # property
		end # listings.each
	end # properties
end #streeteasy
