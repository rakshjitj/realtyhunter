class Building < ActiveRecord::Base
	belongs_to :company
	has_many :units
	
	validates :street_address, presence: true, length: {maximum: 100}, 
						uniqueness: { case_sensitive: false }
						
	validates :zip, presence: true, length: {maximum: 10}

	def active_units
		self.units.where(status: "active")
	end

end
