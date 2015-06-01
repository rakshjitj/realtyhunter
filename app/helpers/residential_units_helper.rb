module ResidentialUnitsHelper
	
	# TODO: this should really be here
	# def bed_and_baths(runit)
 #    "#{runit.beds} / #{runit.baths}"
 #  end

  def rent_formatted(runit)
    number_to_currency(runit.rent, {precision: 0})
  end
	
end
