class CommercialPropertyType < ActiveRecord::Base
	belongs_to :company
	has_many :commercial_units
end
