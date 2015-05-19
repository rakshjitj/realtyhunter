class Building < ActiveRecord::Base
	validates :street_address, presence: true, length: {maximum: 100}, 
						uniqueness: { case_sensitive: false }
						
	validates :zip, presence: true, length: {maximum: 10}

	belongs_to :company
	has_many :units
end
