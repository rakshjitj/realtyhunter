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

#if user.is_management?
#	json.title "Executive Agent"
#elsif user.has_role? :agent
#  json.title "Licensed Real-Estate Agent"
#elsif user.has_role? :unlic_agent
#	json.title "Inactive Real-Estate Agent"
#else
#	json.title "Other"
#end

if user.title == "manager" || 
	user.title == "company admin" || 
	user.title == "data entry" || 
	user.title == "broker" || 
	user.title == "closing manager"

	json.title "Executive Agent"

elsif user.title == "agent"
	json.title "Licensed Real-Estate Agent"

else
	json.title "Other"

end

json.changed_at user.updated_at