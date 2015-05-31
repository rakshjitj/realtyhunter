class Unit < ActiveRecord::Base
	actable
	belongs_to :building
	belongs_to :primary_agent, :foreign_key => 'user_id', :class_name => 'User'

	enum status: [ :active, :pending, :off ]
	validates :status, presence: true, inclusion: { in: %w(active pending off) }
	
	validates :building_unit, presence: true, length: {maximum: 50}
	validates :rent, presence: true, numericality: { only_integer: true }
	validates :listing_id, presence: true, uniqueness: true
	
	
end