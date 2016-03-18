class BuildingLandlordSerializer < ActiveModel::Serializer
  attributes :code, :name, :contact_name, :office_phone, :mobile, :fax, :email, :website, :city,
    :state, :zipcode, :street_address, :location, :listing_agent_id, :listing_agent_percentage,
    :has_fee, :fee_percentage

  def code
  	object.code
  end

  def name
  	object.name
  end

  def contact_name
  	object.contact_name
  end

  def office_phone
  	object.office_phone
  end

  def mobile
  	object.mobile
  end

  def fax
  	object.fax
  end

  def email
  	object.email
  end

  def website
    object.website
  end

  def city
    object.l_sublocality
  end

  def state
    object.l_administrative_area_level_1_short
  end

  def zipcode
    object.l_postal_code
  end

  def street_address
    if object.l_street_number.present? && object.l_route.present?
      object.l_street_number + ' ' + object.l_route
    else
      nil
    end
  end

  def location
    { latitude: object.l_lat, longitude: object.l_lng }
  end

  def listing_agent_id
    object.listing_agent_id
  end

  def listing_agent_percentage
    object.listing_agent_percentage
  end

  def has_fee
    if object.l_has_fee
      'Yes'
    else
      'No'
    end
  end

  def fee_percentage
    if object.l_has_fee
      object.l_tp_fee_percentage
    else
      object.l_op_fee_percentage
    end
  end

end
