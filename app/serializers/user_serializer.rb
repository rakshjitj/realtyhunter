class UserSerializer < ActiveModel::Serializer
  attributes :id, :phone_number, :mobile_phone_number, :email, :bio, :name,
  	:title
  attribute :image, class_name: "Image", serializer: ImageSerializer, key: :headshot
  attribute :updated_at, key: :changed_at

  def title
  	if object.employee_title.name == "agent"
			"Licensed Real-Estate Agent"
		else
			"Other"
		end
  end

  def headshot
    ImageSerializer.new(object.image).attributes
  end

end
