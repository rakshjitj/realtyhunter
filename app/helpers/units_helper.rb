module UnitsHelper

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

	def open_house(residential_unit)
		unit = residential_unit.unit
		descrip = ""
		if unit.open_house
			if unit.oh_exclusive
				descrip = "<strong>EXCLUSIVE!</strong> "
			end
			descrip = descrip + unit.open_house
		end

		descrip.html_safe
	end

end
