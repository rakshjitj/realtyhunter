module ResidentialUnitsHelper
	
	def pet_policy(unit)
		if unit.cached_pet_policy
			unit.cached_pet_policy.name.titleize
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

		descrip.html_safe
	end

	def small_header(unit)
		if unit.cached_neighborhood
			"#{unit.cached_neighborhood.name}, #{unit.cached_building.sublocality}, #{unit.cached_building.administrative_area_level_1_short} #{unit.cached_building.postal_code}"			
		else
			"#{unit.cached_building.sublocality}, #{unit.cached_building.administrative_area_level_1_short} #{unit.cached_building.postal_code}"
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
