module BuildingsHelper
	
	def short_location_title(building)
		if building.neighborhood
      "<small>#{building.neighborhood.name}</small>".html_safe
    else
    	""
    end
	end
end
