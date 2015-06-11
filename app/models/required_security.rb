class RequiredSecurity < ActiveRecord::Base
	belongs_to :company
	has_many :landlords
	before_save :downcase_name

	private

		def downcase_name
      self.name = name.downcase
    end
end
