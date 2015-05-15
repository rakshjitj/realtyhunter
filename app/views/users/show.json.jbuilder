json.extract! @user, :id, :phone_number, :mobile_phone_number, :email, :bio, :name

if @user.avatar_id?
	json.headshot do
  	json.original @user.avatar_url
		json.thumbnail @user.avatar_thumbnail_url
	end
else
	json.headshot do
  	json.original json.null
		json.thumbnail json.null
	end
end

if @user.is_management?
	json.title "Executive Agent"
elsif @user.has_role? :agent
  json.title "Licensed Real-Estate Agent"
elsif @user.has_role? :unlic_agent
	json.title "Inactive Real-Estate Agent"
end
