class BuildingNeighborhoodSerializer < ActiveModel::Serializer
  attributes :name, :area

  def name
  	object.neighborhood_name
  end

  def area
  	object.neighborhood_borough
  end
end
