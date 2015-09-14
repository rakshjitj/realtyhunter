# for use in API active_record serialization only
class Listing
	include ActiveModel::Serialization
	extend ActiveModel::Naming
	include ActiveModel::Conversion
	
	attr_reader :listing, :residential_amenities, :pet_policies,
		:primary_agents, :building_amenities, :images

	def initialize(attributes)
		@listing = attributes[:listing]
		@residential_amenities = attributes[:residential_amenities]
		@pet_policies = attributes[:pet_policies]
		@primary_agents = attributes[:primary_agents]
		@building_amenities = attributes[:building_amenities]
		@images = attributes[:images]
	end

end