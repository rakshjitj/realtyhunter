class Company < ActiveRecord::Base
	attachment :logo
	has_many :offices
	
	validates :name, presence: true, length: {maximum: 50}
end
