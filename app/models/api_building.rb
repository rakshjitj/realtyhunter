# for use in API active_record serialization only
class APIBuilding
  include ActiveModel::Serialization
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_reader :building, :amenities, :images, :id, :updated_at

  def initialize(attributes)
    @building = attributes[:building]
    @amenities = attributes[:amenities]
    @images = attributes[:images]
  end

end
