# This module is designed to match StreetEasy's feed format
# http://streeteasy.com/home/feed_format
module StreetEasyInterface

	def pull_data(company_id, search_params)
		listings = Unit.joins('left join residential_listings on units.id = residential_listings.unit_id
left join commercial_listings on units.id = commercial_listings.unit_id')
		.joins(building: [:neighborhood, :landlord])
		.where('units.archived = false')
		.where('units.status = ?', Units.statuses["active"])
		
		listings = listings
			.select('units.building_unit', 'units.status', 'units.available_by',
			'units.listing_id', 'units.updated_at', 'units.rent',
			'buildings.id as building_id',
			'buildings.administrative_area_level_2_short',
			'buildings.administrative_area_level_1_short',
			'buildings.sublocality',
			'buildings.street_number', 'buildings.route', 
			'buildings.postal_code',
			'buildings.lat',
			'buildings.lng',
			'landlords.code',
			'neighborhoods.name as neighborhood_name',
			'neighborhoods.borough as neighborhood_borough',
			'residential_listings.id AS r_id', 
			'residential_listings.lease_start', 'residential_listings.lease_end', 
			'residential_listings.tp_fee_percentage', 'residential_listings.beds', 
			'residential_listings.baths', 'residential_listings.description',
			'commercial_listings.id as c_id',
			'commercial_listings.lease_term_months', 
			'commercial_listings.property_description', 
			'units.id as unit_id',
			'units.primary_agent_id',
			'units.public_url'
		)

		listings
	end
end