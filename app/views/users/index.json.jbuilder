json.array!(@users) do |user|
  json.extract! user, :id, :fname, :lname, :email, :password_digest, :remember_digest, :bio
  json.url user_url(user, format: :json)
end
