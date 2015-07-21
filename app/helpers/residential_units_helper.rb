module ResidentialUnitsHelper
	
	def pet_policy(residential_unit)
		building = residential_unit.unit.building
		if building.pet_policy
			building.pet_policy_name.titleize
		else
			"-"
		end
	end

	def open_house(residential_unit)
		unit = residential_unit.unit
		descrip = "N/A"
		if unit.open_house
			if unit.oh_exclusive
				descrip = "<strong>EXCLUSIVE!</strong>"
			end
			descrip = descrip + unit.open_house
		end

		descrip.html_safe
	end

	def small_header(residential_unit)
		unit = residential_unit.unit
		if unit
			building = unit.building
			if unit.building.neighborhood
				"#{building.neighborhood.name}, #{building.sublocality}, #{building.administrative_area_level_1_short} #{building.postal_code}"			
			else
				"#{building.sublocality}, #{building.administrative_area_level_1_short} #{building.postal_code}"
			end
		else
			if unit.neighborhood_name
				"#{unit.neighborhood_name}, #{unit.sublocality}, #{unit.administrative_area_level_1_short} #{unit.postal_code}"			
			else
				"#{unit.sublocality}, #{unit.administrative_area_level_1_short} #{unit.postal_code}"
			end
		end
		
	end

	def occupancy_status(unit)
		if unit.tenant_occupied
			'<div class="danger"><strong>TENANT OCCUPIED</strong></div>'.html_safe
		else
			'<strong>Unit vacant</strong>'.html_safe
		end
	end

	def lease_duration(unit)
		str = '';

		if unit.lease_start
			str = str + unit.lease_start
		end

		if unit.lease_end
			str = ' ' + str + ' to ' + unit.lease_end
		end

		str = str + ' Months'

	end

end
