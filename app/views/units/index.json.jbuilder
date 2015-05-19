json.array!(@units) do |unit|
  json.extract! unit, :id, :string, :unit, :beds, :baths, :rent
  json.url unit_url(unit, format: :json)
end
