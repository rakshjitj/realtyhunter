class ResidentialUnit < ActiveRecord::Base
	acts_as :unit
	has_and_belongs_to_many :residential_amenities

	enum lease_duration: [ :half_year, :year, :thirtheen_months, :fourteen_months, :fifteen_months, 
		:sixteen_months, :seventeen_months, :eighteen_months, :two_years ]
	
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

	def self.generate_unique_id
		listing_id = rand(9999999)
    while ResidentialUnit.find_by(listing_id: listing_id) do
      listing_id = rand(9999999)
    end
    listing_id
  end

end
