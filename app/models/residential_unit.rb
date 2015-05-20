class ResidentialUnit < ActiveRecord::Base
	acts_as :unit
	validates :beds, presence: true, :numericality => { :less_than_or_equal_to => 11 }
	validates :baths, presence: true, :numericality => { :less_than_or_equal_to => 11 }
	enum lease_duration: [ :half_year, :year, :one_and_half_years, :two_years ]
end
