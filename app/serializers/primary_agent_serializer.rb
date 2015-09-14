class PrimaryAgentSerializer < ActiveModel::Serializer
  attributes :agent_id, :phone_number, :phone_number, :mobile_phone_number,
    :name, :email

  def agent_id
    object.id
  end

end
