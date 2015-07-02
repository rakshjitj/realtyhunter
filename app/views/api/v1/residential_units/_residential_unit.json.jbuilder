json.prettify! if %w(1 yes true).include?(params["pretty"])

# TODO: check format
json.max_lease_term listing.lease_duration

json.status listing.status
json.min_lease_term listing.lease_duration

if listing.tp_fee_percentage
	json.renter_fee "Fee"
else
	json.renter_fee "No Fee"
end

json.bathrooms listing.baths

json.building do
	json.partial! listing.building, building: listing.building, as: :building
end

json.floor json.nil
json.date_available listing.available_by.strftime('%Y-%m-%d')

json.unit_amenities listing.residential_amenities.map{|a| a.name}
json.unit_description listing.notes

#json.open_houses listing.open_house

json.pets listing.building.pet_policy.name
json.changed_at listing.updated_at

#json.photos
json.square_footage json.nil

json.rent listing.rent

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

json.layout listing.beds_to_s

json.id listing.listing_id