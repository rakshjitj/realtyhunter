# For use in our API
class BuildingBlob
  include ActiveModel::Serialization
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_reader :items, :total_items, :total_pages, :page

  def initialize(attributes)
    @items = attributes[:items]
    @total_items = attributes[:total_count]
    @total_pages = attributes[:total_pages]
    @page = attributes[:page]
  end
end
