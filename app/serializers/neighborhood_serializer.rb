class NeighborhoodSerializer < ActiveModel::Serializer
  attributes :city, :state, :id, :name, :area

  def area
  	object.borough
  end
end
