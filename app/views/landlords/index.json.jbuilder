json.array!(@landlords) do |landlord|
  json.extract! landlord, :id, :code, :name, :phone, :mobile, :fax, :email, :website, :street_address, :city, :state, :zipcode, :notes, :listing_agent_percentage, :management_info
  json.url landlord_url(landlord, format: :json)
end
