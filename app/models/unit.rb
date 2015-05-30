class Unit < ActiveRecord::Base
	actable
	belongs_to :building
	belongs_to :primary_agent, :foreign_key => 'user_id', :class_name => 'User'

	enum status: [ :active, :pending, :off ]
	
	validates :building_unit, presence: true, length: {maximum: 50}
	validates :rent, presence: true, numericality: true
	validates :listing_id, presence: true, uniqueness: true
	
end