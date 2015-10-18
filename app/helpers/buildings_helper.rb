module BuildingsHelper

	def pet_policy(residential_unit)
		building = residential_unit.unit.building
		if building.pet_policy
			if building.pet_policy
				building.pet_policy.name.titleize
			else
				building.pet_policy_name.titleize
			end
		else
			"-"
		end
	end
	
	def short_location_title(building)
		if building.respond_to?("neighborhood_name".to_sym)
			if building.neighborhood_name
	      "<small>#{building.neighborhood_name}</small>".html_safe
	    else
	    	""
	    end
		else
			if building.neighborhood
	      "<small>#{building.neighborhood.name}</small>".html_safe
	    else
	    	""
	    end
	  end
	end
end
