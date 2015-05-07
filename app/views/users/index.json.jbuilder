json.array!(@users) do |user|
  json.extract! user, :id, :fname, :lname, :email, :bio
  json.url user_url(user, format: :json)
end
