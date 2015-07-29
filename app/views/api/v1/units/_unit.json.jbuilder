json.prettify! if %w(1 yes true).include?(params["pretty"])

#puts json.test listing.residential_listing

if listing.residential_listing
	json.listing_type "rental"
	json.property_type "residential"
	#json.commercial_use nil
elsif listing.commercial_listing
	json.listing_type "rental"
	json.property_type "commercial"
	#json.commercial_use listing.commercial_listing.commercial_property_type.property_type
else
	# TODO
	json.listing_type "sales"
	json.property_type "residential"
	#json.commercial_use nil
end

json.unit_number listing.building_unit

if listing.status == "active"
	json.status "Active"
elsif listing.status == "pending"
	json.status "App Pending"
elsif listing.status == "off"
	json.status "Lease Out"
end

if listing.residential_listing
	json.min_lease_term listing.residential_listing.lease_start
	json.max_lease_term listing.residential_listing.lease_end
	if listing.residential_listing.tp_fee_percentage
		json.renter_fee "Fee"
	else
		json.renter_fee "No Fee"
	end
	json.bathrooms listing.residential_listing.baths
	json.unit_amenities listing.residential_listing.residential_amenities.map{|a| a.name}
	json.unit_description listing.residential_listing.description
	json.floor json.nil
	json.layout listing.residential_listing.beds_to_s

elsif listing.commercial_listing
	json.min_lease_term listing.commercial_listing.lease_term_months
	json.max_lease_term listing.commercial_listing.lease_term_months
	json.renter_fee "Fee"
	json.bathrooms nil
	json.unit_amenities nil
	json.unit_description listing.commercial_listing.property_description
	json.floor json.commercial_listing.floor
	json.layout nil

else
	# TODO sales
	json.min_lease_term nil
	json.max_lease_term nil
	json.renter_fee "Fee"
	json.bathrooms nil
	json.unit_amenities nil
	json.unit_description nil
	json.floor json.nil
	json.layout nil
end

#if listing.building
	json.building do
		#json.partial! listing.building, building: listing.building, as: :building

		json.city listing.administrative_area_level_2_short
		json.state listing.administrative_area_level_1_short
		json.zipcode listing.postal_code

		if listing.neighborhood_name
			json.neighborhood do
				json.name listing.neighborhood_name
				json.area listing.neighborhood_borough
			end
		else
			# we don't have info for everything
			json.name nil
			json.area nil
		end

		json.name json.nil
		# TODO json.amenities building.building_amenities.map{|a| a.name}
		json.id json.nil
		json.street_address listing.street_number + ' ' + listing.route #listing.street_address
		json.location do
			json.latitude listing.lat
			json.longitude listing.lng
		end

	end
	
	if listing.pet_policy_name
		json.pets listing.pet_policy_name
	else
		json.pets nil
	end
#end

json.date_available listing.available_by

# TODO
#json.open_houses listing.open_house

json.changed_at listing.updated_at

# TODO
json.photos do
	json.array! listing.images do |i|
		json.large i.file.url(:medium)
		json.is_floorplan false
		json.local_file_name i.file_file_name
		json.small i.file.url(:square)
		json.media_type "10" #i.file.content_type
		json.original i.file.url(:original)
		json.id nil #i.id
		json.thumbnail i.file.url(:thumb)
	end
end

json.square_footage json.nil

json.rent listing.rent

# TODO: commercial agents
json.contacts do 
	json.array! listing.contacts do
		if listing.primary_agent
	  	json.agent_id listing.primary_agent.id
	  	json.phone_number listing.primary_agent.phone_number
	  	json.mobile_phone_number listing.primary_agent.mobile_phone_number
	  	json.name listing.primary_agent.name
	  	json.email listing.primary_agent.email
		end
	end
end

json.id listing.listing_id