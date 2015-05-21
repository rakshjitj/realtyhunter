class Building < ActiveRecord::Base
	belongs_to :company
	belongs_to :landlord
	has_many :units
	
	# TODO: remove this line
	# this is some BS we need to make cancancan happy, because it 
	# does not like our strong parameters
	attr_accessor :building

	validates :formatted_street_address, presence: true, length: {maximum: 100}, 
						uniqueness: { case_sensitive: false }
						
	validates :street_number, presence: true, length: {maximum: 50}
	validates :route, presence: true, length: {maximum: 100}
	# neighborhood can be blank
	#validates :neighborhood, presence: true, length: {maximum: 100}
	# borough
	#:sublocality can be blank
	# city
	validates :administrative_area_level_2_short, presence: true, length: {maximum: 100}
	# state
	validates :administrative_area_level_1_short, presence: true, length: {maximum: 100}
	validates :country_short, presence: true, length: {maximum: 100}
	validates :lat, presence: true, length: {maximum: 100}
	validates :lng, presence: true, length: {maximum: 100}
	validates :place_id, presence: true, length: {maximum: 100}


	def active_units
		self.units.where(status: "active")
	end

end
