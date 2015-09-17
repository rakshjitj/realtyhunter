class SalesAmenity < ActiveRecord::Base
	belongs_to :company, touch: true
	has_and_belongs_to_many :sales_listings
	before_save :downcase_name
	default_scope { order("name ASC") }
	
	validates :company, presence: true
	
	private

		def downcase_name
      self.name = name.downcase
    end
end
