module BuildingsHelper
	
	def short_location_title(building)
		if building.cached_neighborhood
      "<small>#{building.cached_neighborhood.name}</small>".html_safe
    else
    	""
    end
	end
end
