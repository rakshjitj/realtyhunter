json.city building.administrative_area_level_2_short
json.state building.administrative_area_level_1_short
json.zipcode building.postal_code

json.neighborhood do
	json.name building.neighborhood.name
	json.area building.neighborhood.borough
end

json.name json.nil
json.amenities building.building_amenities.map{|a| a.name}
json.id json.nil
json.street_address building.street_address
json.location do
	json.lat building.lat
	json.lng building.lng
end
