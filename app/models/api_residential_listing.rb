# for use in API active_record serialization only
class APIResidentialListing
  include ActiveModel::Serialization
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_reader :listing, :residential_amenities, :pet_policies, :primary_agents,
    :images, :rental_terms, :building_utilities, :open_houses, :building_blob,
    :id, :updated_at

  def initialize(attributes)
    @listing = attributes[:listing]
    @residential_amenities = attributes[:residential_amenities]
    @pet_policies = attributes[:pet_policies]
    @rental_terms = attributes[:rental_terms]
    @building_utilities = attributes[:building_utilities]
    @primary_agents = attributes[:primary_agents]
    @images = attributes[:images]
    @open_houses = attributes[:open_houses]
    @building_blob = attributes[:building_blob]
  end

end
