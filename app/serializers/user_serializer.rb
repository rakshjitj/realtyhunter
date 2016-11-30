class UserSerializer < ActiveModel::Serializer
  attributes :id, :phone_number, :mobile_phone_number, :email, :bio, :name,
  	:title, :headshot
  attribute :updated_at, key: :changed_at

  def title
    if object.respond_to?(:title)
      employee_title_name = object.title
    else
      employee_title_name = object.employee_title.name
    end

  	if employee_title_name == "agent"
			"Licensed Real-Estate Agent"
    elsif employee_title_name == "senior agent"
      "Sr. Licensed Real-Estate Agent"
		else
			"Other"
		end
  end

  def headshot
    ImageSerializer.new(object.image).attributes
  end

end
