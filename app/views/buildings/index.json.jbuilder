json.prettify! if %w(1 yes true).include?(params["pretty"])

json.array!(@buildings) do |building|
  json.extract! building, :id

	json.city building.administrative_area_level_2_short
	json.state building.administrative_area_level_1_short
	json.zipcode building.postal_code
	json.neighborhood building.neighborhood
	json.street_address building.street_address
	json.location do
		json.lat building.lat
		json.lng building.lng
	end

end
