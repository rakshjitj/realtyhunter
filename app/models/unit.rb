class Unit < ActiveRecord::Base
	actable
	belongs_to :building
	enum status: [ :active, :pending, :off ]
	validates :building_unit, presence: true, length: {maximum: 50},
	 uniqueness: { case_sensitive: false }
	validates :rent, presence: true, :numericality => { :less_than_or_equal_to => 1000000000 }
end