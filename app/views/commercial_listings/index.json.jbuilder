json.array!(@commercial_units) do |commercial_unit|
  json.extract! commercial_unit, :id
  json.url commercial_unit_url(commercial_unit, format: :json)
end
