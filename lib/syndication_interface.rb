# This module is designed to match StreetEasy's feed format
# http://streeteasy.com/home/feed_format
module SyndicationInterface

	def is_true?(string)
	  ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(string)
	end

	# search these conditions
	# - must be active
	# - must belong to this company
	# - must be exclusive OR no-fee (though we choose to hide anything unless it's exclusive...)
	# - must have at least 1 listing agent assigned
	def naked_apts_listings(company_id, search_params)
		#search_params[:exclusive] = 1
		search_params[:has_fee_exclusive] = 1
		pull_data(company_id, search_params)
	end
	
	# search these conditions
	# - must be active
	# - must belong to this company
	# - must be exclusive
	# - must have at least 1 listing agent assigned
	# - must have a description
	def streeteasy_listings(company_id, search_params)
		search_params[:exclusive] = 1
		search_params[:must_have_description] = 1
		pull_data(company_id, search_params)
	end

	# search these conditions
	# - must be active
	# - must belong to this company
	# - must have at least 1 listing agent assigned
	def trulia_listings(company_id, search_params)
		pull_data(company_id, search_params)
	end

	def pull_data(company_id, search_params)
		listings = Unit.joins('left join residential_listings on units.id = residential_listings.unit_id
left join commercial_listings on units.id = commercial_listings.unit_id')
		.joins(building: [:company, :neighborhood, :landlord])
		.where('units.archived = false')
		.where('units.status =(?)', Unit.statuses["active"])
		.where('units.primary_agent_id > 0')
		.where('companies.id = ?', company_id)

		# naked requires all no-fee listings to be exposed
		# so we have to filter out the non-exclusive ones on our end
		if is_true?(search_params[:has_fee_exclusive])
			listings = listings.where('residential_listings.has_fee = TRUE OR (residential_listings.has_fee = FALSE AND units.exclusive = TRUE)')
		end

		if is_true?(search_params[:exclusive])
			listings = listings.where('units.exclusive = TRUE')
		end

		if is_true?(search_params[:must_have_description])
			listings = listings.where("residential_listings.description <> '' OR commercial_listings.property_description <> '' ")
		end

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
			'residential_listings.has_fee', 'residential_listings.beds', 
			'residential_listings.baths', 'residential_listings.description',
			'commercial_listings.id as c_id',
			'commercial_listings.lease_term_months', 
			'commercial_listings.property_description', 
			'units.id as unit_id',
			'units.primary_agent_id',
			'units.public_url',
			'units.exclusive'
		)

		listings
	end
end