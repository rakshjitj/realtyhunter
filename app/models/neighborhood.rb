class Neighborhood < ActiveRecord::Base
	has_many :buildings

	validates :name, presence: true, length: {maximum: 100}, 
		uniqueness: { case_sensitive: false }

	def self.forCity(city)
		Neighborhood.where(city: city).all
	end

	def self.forBorough(borough)
		Neighborhood.where(borough: borough).all
	end
	
end
