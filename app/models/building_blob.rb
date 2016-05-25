# For use in our API
class BuildingBlob
  include ActiveModel::Serialization
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_reader :items, :total_items, :total_pages, :page

  def initialize(attributes)
    @items = attributes[:buildings]
    @total_items = @items.total_count
    @total_pages = @items.total_pages
    @page = @items.current_page
  end
end
