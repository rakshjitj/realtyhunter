json.prettify! if %w(1 yes true).include?(params["pretty"])

	json.listing_type "rental"
	json.property_type "residential"
	json.commercial_use nil

	json.min_lease_term listing.lease_start
	json.max_lease_term listing.lease_end
	if listing.tp_fee_percentage
		json.renter_fee "Fee"
	else
		json.renter_fee "No Fee"
	end
	json.bathrooms listing.baths
	
	if @residential_amenities[listing.unit_id]
		json.unit_amenities @residential_amenities[listing.unit_id].map{|a| a.name}
	else
		json.unit_amenities nil
	end

	json.unit_description listing.description
	json.floor json.nil
	
	json.layout listing.beds == 0 ? "Studio" : (listing.beds.to_s + ' Bedroom')

	json.unit_number listing.building_unit

	if @pet_policies[listing.building_id]
		json.pets @pet_policies[listing.building_id][0].pet_policy_name
	else
		json.pets nil
	end

	json.contacts do 
		json.array! @primary_agents[listing.primary_agent_id] do |agent|
		  # TODO: do we have to display this db id?
	  	json.agent_id agent.id
	  	json.phone_number agent.phone_number
	  	json.mobile_phone_number agent.mobile_phone_number
	  	json.name agent.name
	  	json.email agent.email
		end
	end


if listing.status == "active"
	json.status  "Available"

elsif listing.status == "pending" ||
listing.status == "offer_submitted" ||
listing.status == "offer_accepted" ||
listing.status == "binder_signed"

	json.status "App Pending"

elsif listing.status == "off" ||
listing.status == "off_market_for_lease_execution"
	
	json.status "Lease Out"

end


json.building do
	json.city listing.sublocality # should display city (brooklyn, new york)
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
	
	if @building_amenities[listing.building_id]
		json.amenities @building_amenities[listing.building_id].map{|b| b.name}
	else
		json.amenities nil
	end

	json.id json.nil
	json.street_address listing.street_number + ' ' + listing.route #listing.street_address
	json.location do
		json.latitude listing.lat
		json.longitude listing.lng
	end
end

json.date_available listing.available_by

# TODO
#json.open_houses listing.open_house

json.changed_at listing.updated_at

json.square_footage json.nil

json.rent listing.rent

json.id listing.listing_id

json.photos do
	json.array! @images[listing.unit_id] do |i|
		json.large i.file.url(:medium)
		json.is_floorplan false
		json.local_file_name i.file_file_name
		json.small i.file.url(:square)
		json.media_type "10" #i.file.content_type
		json.original i.file.url(:original)
		json.id nil # don't return db id if we don't have to
		json.thumbnail i.file.url(:thumb)
	end
end
