json.array!(@building_amenities) do |building_amenity|
  json.extract! building_amenity, :id, :name
  json.url building_amenity_url(building_amenity, format: :json)
end
