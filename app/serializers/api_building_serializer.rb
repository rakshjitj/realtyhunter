class APIBuildingSerializer < ActiveModel::Serializer
  attributes :city, :state, :zipcode, :id, :street_address, :location, :llc_name,
      :neighborhood, :landlord, :photos, :amenities

  # note: utilities are on the building object. they should really be returned here, not on the
  # listing. however since we initially built this API to match Nestio's, we decided to
  # list them there instead. should fix one day.

  # def is_sales
  #   object.respond_to?(:s_id) && object.s_id
  # end

  def neighborhood
    BuildingNeighborhoodSerializer.new(object.building).attributes
  end

# #  attribute :landlord
  def landlord
    #if !is_sales && object.respond_to?(:code)
      LandlordSerializer.new(object.building).attributes
    #else
    #  nil
    #end
  end

  def photos
    if object.images
      object
        .images
        .map {|x| ListingImageSerializer.new(x).attributes}
    end
  end

  def city
  	# should display city (brooklyn, new york)
    object.building.b_sublocality
  end

  def state
  	object.building.b_administrative_area_level_1_short
  end

  def zipcode
  	object.building.b_postal_code
  end

  # todo: not used. only added for consistency with nestio API. should be removed at a future date.
  def name
  	nil
  end

  def id
  	object.building.id
  end

  def street_address
  	object.building.b_street_number + ' ' + object.building.b_route
  end

  def location
  	{latitude: object.building.b_lat, longitude: object.building.b_lng}
  end

  def llc_name
    object.building.llc_name
  end

  def amenities
    if object.amenities
      object.amenities.map{|a| a.name}
    else
      nil
    end
  end
end
