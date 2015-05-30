module ResidentialUnitsHelper

	def rent_formatted(unit)
		number_to_currency(unit.rent, {precision: 0})
	end
	
end
