class BuildingAmenity < ActiveRecord::Base
	belongs_to :company, touch: true
	has_and_belongs_to_many :buildings
	before_save :downcase_name
	default_scope { order("name ASC") }

	private

		def downcase_name
      self.name = name.downcase
    end
end
