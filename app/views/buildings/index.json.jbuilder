json.array!(@buildings) do |building|
  json.extract! building, :id, :street_address, :zip, :private_notes
  json.url building_url(building, format: :json)
end
