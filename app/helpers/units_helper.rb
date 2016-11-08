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

		viewable_fields = ['beds', 'baths', 'rented date', 'access info', 'description', 'notes',
				'status']
		audit.audited_changes.each do |key, val|
			key = key.gsub('_', ' ')
			if key == 'rent' || key == 'price'
				retVal.push("#{key} from $#{val[0]} to $#{val[1]}")
			elsif viewable_fields.include? key
				retVal.push("#{key}")
			end
		end

		if retVal.length > 0
			"#{audit.user.name} changed #{retVal.join(', ')} on #{audit.created_at}."
		else
			"#{audit.user.name} made changes on #{audit.created_at}."
		end
	end

end
