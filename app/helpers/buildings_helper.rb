module BuildingsHelper
	
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
