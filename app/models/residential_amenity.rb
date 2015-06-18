class ResidentialAmenity < ActiveRecord::Base
	belongs_to :company
	has_and_belongs_to_many :residential_units
	before_save :downcase_name
	default_scope { order("name ASC") }
	
	validates :company, presence: true
	
	private

		def downcase_name
      self.name = name.downcase
    end
end
