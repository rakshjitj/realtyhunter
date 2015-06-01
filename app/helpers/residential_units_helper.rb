module ResidentialUnitsHelper
	
  def rent_formatted(rent)
    number_to_currency(rent, {precision: 0})
  end
	
end
