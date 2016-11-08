module UnitsHelper

	def occupancy_status(unit)
		if unit.tenant_occupied
			'<strong>Tenant Occupied</strong>'.html_safe
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

	def pretty_audit_changes(audit)
		retVal = []
		audit.audited_changes.each do |key, val|
			key = key.gsub('_', ' ')
			if key == 'rent' || key == 'price'
				retVal.push("#{key} from $#{val[0]} to $#{val[1]}")
			else
				retVal.push("#{key}")
			end

		end

		"#{audit.user.name} changed #{retVal.join(', ')} on #{audit.created_at}."
	end

end
