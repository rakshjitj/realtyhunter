# For use in our API
class LandlordBlobSerializer < ActiveModel::Serializer
  attributes :total_items, :total_pages, :page
  has_many :items, class_name: "Landlord", each_serializer: LandlordSerializer
end
