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
		search_params[:has_primary_agent] = 1
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
		search_params[:has_primary_agent] = 1
		search_params[:exclusive] = 1
		search_params[:must_have_description] = 1
		pull_data(company_id, search_params)
	end

	# search these conditions
	# - must be active
	# - must belong to this company
	# - must have at least 1 listing agent assigned
	def trulia_listings(company_id, search_params)
		search_params[:has_primary_agent] = 1
		pull_data(company_id, search_params)
	end

	def nestio_listings(company_id, search_params)
		search_params[:is_nestio] = 1
		pull_data(company_id, search_params)
	end

	def pull_data(company_id, search_params)
		listings = Unit.joins('left join residential_listings on units.id = residential_listings.unit_id
left join sales_listings on units.id = sales_listings.unit_id')
		# Notes:
		# - Left join on the landlords because sales listings do not have a landlord defined.
		# - Since we are joining of the base Unit table, make sure no commerical listings are included.
		 #  We want to only include units that are sales or residential listings.
		listings = listings.joins([building: :company])
			.joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
			.joins('left join landlords on landlords.id = buildings.landlord_id')
			.where('units.archived = false')
			.where('residential_listings.id IS NOT NULL OR sales_listings.id IS NOT NULL')
			.where('companies.id = ?', company_id)

		# Nestio is still viewed as another "internal system". We send them our data, but we treat this
		# as more of different "frontend" for our listings. Ignore the syndication status flag in their case.
		if is_true?(search_params[:is_nestio])
			listings = listings.where('units.status IN (?)',
					[Unit.statuses["active"], Unit.statuses["pending"]])
		else
			listings = listings.where('units.status IN (?) OR units.syndication_status = ?',
					[Unit.statuses["active"], Unit.statuses["pending"]],
					Unit.syndication_statuses['Force syndicate'])
				.where('units.syndication_status IN (?)', [
					Unit.syndication_statuses['Syndicate if matches criteria'],
					Unit.syndication_statuses['Force syndicate']
				])
		end

		if is_true?(search_params[:has_primary_agent])
			listings = listings.where('units.primary_agent_id > 0')
		end

		# naked requires all no-fee listings to be exposed
		# so we have to filter out the non-exclusive ones on our end
		if is_true?(search_params[:has_fee_exclusive])
			listings = listings.where('residential_listings.has_fee = TRUE OR (residential_listings.has_fee = FALSE AND units.exclusive = TRUE)')
		end

		if is_true?(search_params[:exclusive])
			listings = listings.where('units.exclusive = TRUE')
		end

		if is_true?(search_params[:must_have_description])
			listings = listings.where("residential_listings.description <> '' OR sales_listings.public_description <> '' ")
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
			'residential_listings.has_fee', 'residential_listings.beds as r_beds',
			'residential_listings.baths as r_baths', 'residential_listings.description',
			'residential_listings.total_room_count as r_total_room_count',
			'residential_listings.floor',
			'residential_listings.tenant_occupied as r_tenant_occupied',
			'sales_listings.id AS s_id',
			'sales_listings.beds as s_beds',
			'sales_listings.baths as s_baths',
			'sales_listings.public_description',
			'sales_listings.tenant_occupied as s_tenant_occupied',
			'units.id as unit_id',
			'units.primary_agent_id',
			'units.primary_agent2_id',
			'units.public_url',
			'units.exclusive')

		# puts "\n\n\n****** #{listings.length}"
		listings.uniq
	end
end
