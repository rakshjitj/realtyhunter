# For use in our API
class AgentBlobSerializer < ActiveModel::Serializer
  attributes :total_items, :total_pages, :page
  has_many :items, class_name: "User", each_serializer: UserSerializer
end
