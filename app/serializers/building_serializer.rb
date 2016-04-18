class BuildingSerializer < ActiveModel::Serializer
  attributes :city, :state, :zipcode, :name, :id, :street_address, :location

  def is_sales
    object.respond_to?(:s_id) && object.s_id
  end

  attribute :neighborhood
  def neighborhood
    BuildingNeighborhoodSerializer.new(object).attributes
  end

  attribute :landlord
  def landlord
    if !is_sales
      BuildingLandlordSerializer.new(object).attributes
    else
      nil
    end
  end

  def city
  	# should display city (brooklyn, new york)
  	object.b_sublocality
  end

  def state
  	object.b_administrative_area_level_1_short
  end

  def zipcode
  	object.b_postal_code
  end

  def name
  	nil
  end

  def id
  	nil
  end

  def street_address
  	object.b_street_number + ' ' + object.b_route
  end

  def location
  	{ latitude: object.b_lat, longitude: object.b_lng }
  end
end
