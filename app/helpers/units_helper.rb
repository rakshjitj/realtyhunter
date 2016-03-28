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

end
