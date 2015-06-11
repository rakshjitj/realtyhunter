class RentalTerm < ActiveRecord::Base
	belongs_to :company
	has_and_belongs_to_many :buildings
	before_save :downcase_name

	private

		def downcase_name
      self.name = name.downcase
    end

end
