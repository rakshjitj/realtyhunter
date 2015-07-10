class RentalTerm < ActiveRecord::Base
	belongs_to :company, touch: true
	has_many :buildings
	before_save :downcase_name

	validates :company, presence: true
	
	private

		def downcase_name
      self.name = name.downcase
    end
end
