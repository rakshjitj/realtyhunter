json.prettify! if %w(1 yes true).include?(params["pretty"])

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


if listing.status == "active"
	json.status  "Active"

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
	json.street_address listing.street_number + ' ' + listing.route
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

