class Room < ApplicationRecord
	belongs_to :residential_listing
	has_many :images, :dependent => :destroy
	has_many :pictures, :dependent => :destroy
	accepts_nested_attributes_for :pictures, allow_destroy: true
end
