module ResidentialUnitsHelper
	
  def rent_formatted(runit)
    number_to_currency(runit.rent, {precision: 0})
  end
	
end
