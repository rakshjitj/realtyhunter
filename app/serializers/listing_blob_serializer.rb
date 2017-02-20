# For use in our API
class ListingBlobSerializer < ActiveModel::Serializer
  attributes :total_items, :total_pages, :page, :items
  # has_many :items, polymorphic: true # class_name: "Listing" #, each_serializer: ListingSerializer
  has_many :items#, polymorphic: true, each_serializer: APIResidentialListingSerializer
end

