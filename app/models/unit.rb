class Unit < ActiveRecord::Base
	actable
	belongs_to :building

	validates :building_unit, presence: true, length: {maximum: 50},
	 uniqueness: { case_sensitive: false }
	validates :rent, presence: true, :numericality => { :less_than_or_equal_to => 1000000000 }
end

class ResidentialUnit < ActiveRecord::Base
	acts_as :unit
	validates :beds, presence: true, :numericality => { :less_than_or_equal_to => 11 }
	validates :baths, presence: true, :numericality => { :less_than_or_equal_to => 11 }
end

class CommercialUnit < ActiveRecord::Base
	acts_as :unit
end