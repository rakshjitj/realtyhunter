# For use in our API
class ListingBlobSerializer < ActiveModel::Serializer
  attributes :total_items, :total_pages, :page
  has_many :items, class_name: "Listing", each_serializer: ListingSerializer
end
