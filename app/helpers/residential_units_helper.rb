module ResidentialUnitsHelper

	def rent_formatted
		number_to_currency(@residential_unit.rent, {precision: 0})
	end
	
end
