module ResidentialListingsHelper

	def small_header(residential_unit)
		unit = residential_unit.unit
		if unit
			building = unit.building
			if unit.building.neighborhood
				"#{building.neighborhood.name}, #{building.sublocality}, #{building.administrative_area_level_1_short} #{building.postal_code}".freeze
			else
				"#{building.sublocality}, #{building.administrative_area_level_1_short} #{building.postal_code}".freeze
			end
		else
			if unit.neighborhood_name
				"#{unit.neighborhood_name}, #{unit.sublocality}, #{unit.administrative_area_level_1_short} #{unit.postal_code}".freeze
			else
				"#{unit.sublocality}, #{unit.administrative_area_level_1_short} #{unit.postal_code}".freeze
			end
		end

	end

	def trim_access text
		if !text.nil? && text.size > 47
			text[0..47] + '...'.freeze
		else
			text
		end
	end

	def roommate_has_icon(roommates, idx)
		return idx < roommates.count && roommates[idx] && roommates[idx].upload_picture_of_yourself
	end

	def beds_as_str(residential_listing)
		if residential_listing.beds == 0
      "Studio ".freeze
    else
      "#{residential_listing.beds}".freeze
    end
	end

	def baths_as_str(residential_listing)
		if residential_listing.baths == 1
      "#{trim_zeros(residential_listing.baths)}".freeze
    else
      "#{trim_zeros(residential_listing.baths)}".freeze
    end
	end

end
