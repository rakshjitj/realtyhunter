json.array!(@googles) do |google|
  json.extract! google, :id
  json.url google_url(google, format: :json)
end
