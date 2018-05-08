class Specialty < ApplicationRecord
	belongs_to :company, touch: true
	has_and_belongs_to_many :users
end
