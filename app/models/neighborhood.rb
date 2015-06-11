class Neighborhood < ActiveRecord::Base
	has_many :buildings

	scope :unarchived, ->{where(archived: false)}

	validates :name, presence: true, length: {maximum: 100}, 
		uniqueness: { case_sensitive: false }

	def self.for_city(city)
		Neighborhood.unarchived.where(city: city).all
	end

	def self.for_borough(borough)
		Neighborhood.unarchived.where(borough: borough).all
	end
	
end
