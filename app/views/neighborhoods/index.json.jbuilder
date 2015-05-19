json.array!(@neighborhoods) do |neighborhood|
  json.extract! neighborhood, :id, :name, :borough
  json.url neighborhood_url(neighborhood, format: :json)
end
