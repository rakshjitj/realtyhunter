json.prettify! if %w(1 yes true).include?(params["pretty"])

json.max_lease_term listing.lease_end

json.status listing.unit.status
json.min_lease_term listing.lease_start

if listing.tp_fee_percentage
	json.renter_fee "Fee"
else
	json.renter_fee "No Fee"
end

json.bathrooms listing.baths

json.building do
	json.partial! listing.unit.building, building: listing.unit.building, as: :building
end

json.floor json.nil
json.date_available listing.unit.available_by

json.unit_amenities listing.residential_amenities.map{|a| a.name}
json.unit_description listing.notes

#json.open_houses listing.unit.open_house

if listing.unit.building.pet_policy
	json.pets listing.unit.building.pet_policy.name
end

json.changed_at listing.updated_at

#json.photos
json.square_footage json.nil

json.rent listing.unit.rent

json.contacts do 
	json.array! listing.contacts do
		if listing.unit.primary_agent
	  	json.agent_id listing.unit.primary_agent.id
	  	json.phone_number listing.unit.primary_agent.phone_number
	  	json.mobile_phone_number listing.unit.primary_agent.mobile_phone_number
	  	json.name listing.unit.primary_agent.name
	  	json.email listing.unit.primary_agent.email
		end
	end
end

json.layout listing.beds_to_s

json.id listing.unit.listing_id