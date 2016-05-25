# For use in our API
class BuildingBlobSerializer < ActiveModel::Serializer
  attributes :total_items, :total_pages, :page
  has_many :items, class_name: "Building", each_serializer: BuildingSerializer
end
