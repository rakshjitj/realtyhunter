class RequiredSecurity < ActiveRecord::Base
	belongs_to :company
	has_many :landlords
end
