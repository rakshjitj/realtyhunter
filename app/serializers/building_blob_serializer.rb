# For use in our API
class BuildingBlobSerializer < ActiveModel::Serializer
  attributes :total_items, :total_pages, :page, :items
  has_many :items, class_name: 'APIBuilding', each_serializer: APIBuildingSerializer
end
