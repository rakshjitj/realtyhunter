# todo: before re-enabling caching here, need to figure out how to expire the cache here
# when a building photo is updated. the building photo is displayed before listings photos,
# but adding/removing building photos does not update the listing object.
#cache "trulia/#{@listings.ids.join('')}-#{@listings.ids.count}-#{@listings.maximum(:updated_at).to_i}-" do

# url looks like <base_url>/syndication/1/trulia
xml.instruct! :xml, :version => "1.0"

xml.hotPadsItems version:"2.1" do

	xml.company id: @company.id do
		xml.name @company.name
		xml.website @company.website
		#xml.city @company.city
		#xml.state @company.state
		xml.company_logo source: @company.image.file.url(:large)
	end

	@listings.each do |listing|
		xml.listing id: listing.listing_id, type: "RENTAL", companyId:@company.id, propertyType:"CONDO" do
			#xml.name
			xml.unit listing.building_unit

			if listing.exclusive
				xml.street listing.street_number + " " + listing.route, hide:"false"
			else
				xml.street listing.street_number + " " + listing.route, hide:"true"
			end

			xml.city listing.sublocality
			xml.state listing.administrative_area_level_1_short
			xml.zip listing.postal_code
			#xml.country "USA"
			xml.latitude listing.lat
			xml.longitude listing.lng
			# must be full time
			xml.lastUpdated listing.updated_at.strftime('%FT%T%:z')
			# only accepts 1 contact on residential listings
			if @primary_agents[listing.unit_id]
				agent = @primary_agents[listing.unit_id][0]
				xml.contactName agent.name
				xml.contactEmail agent.email
				xml.contactPhone agent.mobile_phone_number
				xml.contactFax agent.office_fax
				#xml.contactTimes
			end

			# TODO
			# <openHouses>
			# 					<openHouse>	<!-- repeatable	-->
			# 									<date/>
			# 									<startTime/>
			# 									<endTime/>
			# 									<appointmentRequired/>
			# 					</openHouse>
			# 	</openHouses>
			# xml.openHouses do
			# 	xml.openHouse do
			# 		xml.date
			# 		xml.startTime
			# 		xml.endTime
			# 		xml.appointmentRequired
			# 	end
			# end

			tmp_descrip = h raw sanitize listing.description, tags: %w()

			xml.previewMessage tmp_descrip ? tmp_descrip[0..255] : tmp_descrip
			xml.description tmp_descrip
			xml.terms # TODO
			# terms>One year lease, then month to month. Deposit equals first month's rent</terms>
			xml.leaseTerm "OneYear"
			xml.website listing.public_url
			#xml.virtual_tour_url

			if @building_amenities[listing.building_id]
				@building_amenities[listing.building_id].map{|b| b.name}.each do |bm|
					if bm == "laundry in building"
						xml.listingTag type:"LAUNDRY" do
							xml.tag "SHARED"
						end
					else
						xml.listingTag type:"PROPERTY_AMENITY" do
							xml.tag bm
						end
					end
				end
			end

			if @residential_amenities && @residential_amenities[listing.unit_id]
				@residential_amenities[listing.unit_id].map{|a| a.name}.each do |rm|
					xml.listingTag type:"MODEL_AMENITY" do
						if rm == "laundry_in_unit" || rm == "washer/dryer" || rm == "washer/dryer in unit"
							xml.listingTag type:"LAUNDRY" do
								xml.tag "IN_UNIT"
							end
						else
							xml.tag rm
						end
					end

				end
			end

			if !@utilities[listing.building_id].blank?
				@utilities[listing.building_id].each do |u|
					xml.listingTag type:"RENT_INCLUDES" do
						xml.tag u.utility_name
					end
				end
			end

			if !@pet_policies[listing.building_id].blank?
				# any dog allowed
				dogsAllowed = true
				pet_policy = @pet_policies[listing.building_id][0].pet_policy_name
				if pet_policy == "cats only" ||
					pet_policy == "no pets"
					dogsAllowed = false
				end

				xml.listingTag type:"DOGS_ALLOWED" do
					xml.tag dogsAllowed
				end

				# small dogs allowed
				if pet_policy == "small pets ok (<30 lbs)"
					xml.listingTag type:"SMALL_DOGS_ALLOWED" do
						xml.tag true
					end
				end

				# cats allowed
				catsAllowed = true
				if pet_policy == "dogs only" ||
					pet_policy == "no pets"
					catsAllowed = false
				end

				xml.listingTag type:"CATS_ALLOWED" do
					xml.tag catsAllowed
				end
			end

			if @primary_agents[listing.primary_agent_id]
				agent = @primary_agents[listing.primary_agent_id][0]
				xml.listingPermission agent.email
			end

			if @bldg_images[listing.building_id]
				@bldg_images[listing.building_id].each do |i|
					xml.listingPhoto source:i.file.url(:large) do #repeatable
						#xml.label
						#xml.caption
					end
				end
			end
			if @images[listing.unit_id]
				@images[listing.unit_id].each do |i|
					xml.listingPhoto source:i.file.url(:large) do #repeatable
						#xml.label
						#xml.caption
					end
				end
			end

			xml.price listing.rent
			xml.pricingFrequency "MONTH"
			#xml.HOA-FEE
			#xml.deposit
			xml.numBedrooms listing.beds
			if listing.baths
				xml.numFullBaths listing.baths.to_i

				decimal_idx = listing.baths.to_s.index('.')
				if decimal_idx > -1
					xml.numHalfBaths 1
				end
			end
			#xml.squareFeet
			if listing.available_by
				xml.dateAvailable listing.available_by.strftime("%Y-%m-%d")
			end
		end
	end

end
#end #cache
