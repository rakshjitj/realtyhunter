json.array!(@residential_units) do |residential_unit|
  json.extract! residential_unit, :id
  json.url residential_unit_url(residential_unit, format: :json)
end
