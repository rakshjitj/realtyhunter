class BuildingSerializer < ActiveModel::Serializer
  attributes :city, :state, :zipcode, :name, :id, :street_address, :location
  
  attribute :neighborhood, serializer: BuildingNeighborhoodSerializer
  def neighborhood
    BuildingNeighborhoodSerializer.new(object.neighborhood).attributes
  end

  def city
  	# should display city (brooklyn, new york)
  	object.sublocality
  end

  def state
  	object.administrative_area_level_1_short
  end

  def zipcode
  	object.postal_code
  end

  def name
  	nil
  end

  def id
  	nil
  end

  def street_address
  	object.street_number + ' ' + object.route
  end

  def location
  	{ latitude: object.lat, longitude: object.lng }
  end
end
