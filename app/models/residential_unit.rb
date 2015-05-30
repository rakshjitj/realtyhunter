class ResidentialUnit < ActiveRecord::Base
	acts_as :unit
	has_and_belongs_to_many :residential_amenities

	enum lease_duration: [ :half_year, :year, :one_and_half_years, :two_years ]
	
	validates :beds, presence: true, :numericality => { :less_than_or_equal_to => 11 }
	validates :baths, presence: true, :numericality => { :less_than_or_equal_to => 11 }

	def amenities_to_s
		amenities = self.residential_amenities.map{|a| a.name}
		if amenities
			amenities.join(", ")
		else
			"None"
		end
	end

end
