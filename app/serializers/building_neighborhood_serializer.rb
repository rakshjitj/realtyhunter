class BuildingNeighborhoodSerializer < ActiveModel::Serializer
  attributes :name, :area

  def name
  	object.name
  end

  def area
  	object.borough
  end
end
