json.city building.administrative_area_level_2_short
json.state building.administrative_area_level_1_short
json.zipcode building.postal_code
json.county

if building.neighborhood
	json.neighborhood do
		json.name building.neighborhood.name
		json.area building.neighborhood.borough
	end
else
	# we don't have info for everything
	json.name nil
	json.area nil
end

json.name json.nil
json.amenities building.building_amenities.map{|a| a.name}
json.id json.nil
json.street_address building.street_address
json.location do
	json.latitude building.lat
	json.longitude building.lng
end
