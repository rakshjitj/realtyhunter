json.array!(@users) do |user|
  json.extract! user, :id, :phone_number, :mobile_phone_number, :email, :bio
  json.name user.fname + " " + user.lname
  
  if user.avatar_key?
  	json.headshot do
	  	json.original user.avatar_url
  		json.thumbnail user.avatar_thumbnail_url
  	end
  else
  	json.headshot do
	  	json.original json.null
  		json.thumbnail json.null
  	end
  end
  

  json.title "Licensed Real-Estate Broker"
end
