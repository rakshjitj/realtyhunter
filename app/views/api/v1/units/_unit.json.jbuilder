json.prettify! if %w(1 yes true).include?(params["pretty"])

if @listing_type == 10
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
	
	json.unit_amenities listing.residential_amenities.map{|a| a.name}
	
	json.unit_description listing.description
	json.floor json.nil
	json.layout listing.beds_to_s
	json.unit_number listing.building_unit

	if listing.pet_policy_name
		json.pets listing.pet_policy_name
	else
		json.pets nil
	end

	# TODO: commercial
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

elsif @listing_type == 20
	# TODO
	json.listing_type "sales"
	json.property_type "residential"
	#json.commercial_use nil

	json.min_lease_term nil
	json.max_lease_term nil
	json.renter_fee "Fee"
	json.bathrooms nil
	json.unit_amenities nil
	json.unit_description nil
	json.floor json.nil
	json.layout nil

elsif @listing_type == 30
	json.listing_type "rental"
	json.property_type "commercial"
	#json.commercial_use listing.commercial_property_type.property_type

	json.min_lease_term listing.lease_term_months
	json.max_lease_term listing.lease_term_months
	json.renter_fee "Fee"
	json.bathrooms nil
	json.unit_amenities nil
	json.unit_description listing.property_description
	json.floor json.floor
	json.layout nil

end

if listing.status == Unit.statuses["active"]
	json.status  "Active"

elsif listing.status == Unit.statuses["pending"] ||
listing.status == Unit.statuses["offer_submitted"] ||
listing.status == Unit.statuses["offer_accepted"] ||
listing.status == Unit.statuses["binder_signed"]

	json.status "App Pending"

elsif listing.status == Unit.statuses["off"] ||
listing.status == Unit.statuses["off_market_for_lease_execution"]
	json.status "Lease Out"

end

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
	# TODO json.amenities unit.building.building_amenities.map{|a| a.name}
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
		json.id nil #i.id
		json.thumbnail i.file.url(:thumb)
	end
end

