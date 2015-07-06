module ResidentialUnitsHelper
	
	def pet_policy(unit)
		if unit.building.pet_policy
			unit.building.pet_policy.name.titleize
		else
			"-"
		end
	end

	def open_house(unit)
		descrip = "N/A"
		if unit.open_house
			if unit.oh_exclusive
				descrip = "<strong>EXCLUSIVE!</strong>"
			end
			descrip = descrip + unit.open_house
		end

		descrip
	end

	def small_header(unit)
		if unit.building.neighborhood
			"#{unit.building.sublocality}, #{unit.building.administrative_area_level_1_short} #{unit.building.postal_code}"
		else
			"#{unit.building.neighborhood.name}, #{unit.building.sublocality}, #{unit.building.administrative_area_level_1_short} #{unit.building.postal_code}"
		end	
		
	end

end
