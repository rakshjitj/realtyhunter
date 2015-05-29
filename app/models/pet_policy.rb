class PetPolicy < ActiveRecord::Base
	belongs_to :company
	has_many :landlords
end
