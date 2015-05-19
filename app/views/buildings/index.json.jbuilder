json.array!(@buildings) do |building|
  json.extract! building, :id, :address, :private_notes
  json.url building_url(building, format: :json)
end
