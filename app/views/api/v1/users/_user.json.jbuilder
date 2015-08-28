json.prettify! if %w(1 yes true).include?(params["pretty"])

json.extract! user, :id, :phone_number, :mobile_phone_number, :email, :bio, :name

if user.image
	json.headshot do
  	json.original user.image.file.url(:original)
		json.thumbnail user.image.file.url(:thumb)
	end
else
	json.headshot do
  	json.original json.null
		json.thumbnail json.null
	end
end

if user.title == "agent"
	json.title "Licensed Real-Estate Agent"
else
	json.title "Other"
end

json.changed_at user.updated_at