module API
	module V1
		# This module is designed to match Nestio's search API

		# designed to match: http://developers.nestio.com/api/v1/

		# params: key (required)

		# response codes
		# 200 - success, 400 - invalid params, 403 - invalid API key

		# example request
		# https://nestiolistings.com/api/v1/public/listings/?layout=10&min_rent=1500&max_rent=2000&key={API KEY}

		# acceptable search params:
		# listing_type, layout, bathrooms, min/max rent, cats/dogs_allowed,
		# elevator, doorman, date_available_after/before, laundry_in_building,
		# laundry_in_unit, has_photos, featured, neighborhoods, geometry, agents,
		# sort, sort_dir, per_page

		module NestioInterface

			def to_boolean(s)
			  !!(s =~ /^(true|t|yes|y|1)$/i)
			end

			def neighborhood_search(search_params)
				neighborhoods = Neighborhood.where(archived: false)

				if search_params[:city] && !search_params[:city].empty?
					# put a cap on text length
					city = search_params[:city][0..250]
					neighborhoods = neighborhoods.where('city = ?', city)
				end

				if search_params[:state] && !search_params[:state].empty?
					# put a cap on text length - 2 letter state abbreviation
					state = search_params[:state][0..2]
					neighborhoods = neighborhoods.where('state = ?', state)
				end

				# TODO - Unused param from Nestio:
				# company_building_limit optional - Passing true to this option will limit the neighborhoods returned to those that the company owns buildings in.
				neighborhoods
			end

			def all_listings_search(company_id, search_params)
				listings = Unit.joins('left join residential_listings on units.id = residential_listings.unit_id
left join commercial_listings on units.id = commercial_listings.unit_id')
				.joins(building: :neighborhood)
				.where('units.archived = false')
				.where('units.status IN (?)', Unit.statuses["active"])

				if search_params[:id] && !search_params[:id].empty?
					listings = listings.where('units.listing_id = ?', search_params[:id])
				else
					listings = _restrict_on_unit_model(company_id, search_params, listings)
					listings = _restrict_on_residential_model(company_id, search_params, listings)
					listings = _sort_by(search_params, listings)
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
					'neighborhoods.name as neighborhood_name',
					'neighborhoods.borough as neighborhood_borough',
					'residential_listings.id AS r_id',
					'residential_listings.lease_start', 'residential_listings.lease_end',
					'residential_listings.tp_fee_percentage', 'residential_listings.beds',
					'residential_listings.baths', 'residential_listings.description',
					'residential_listings.favorites as r_favorites', 'residential_listings.show as r_show',
					'residential_listings.expose_address as r_expose_address',
					'residential_listings.floor_number', 'residential_listings.total_room_count',
					'residential_listings.condition', 'residential_listings.showing_instruction',
					'residential_listings.commission_amount', 'residential_listings.cyof',
					'residential_listings.rented_date', 'residential_listings.rlsny',
					'residential_listings.share_with_brokers',
					'commercial_listings.id as c_id',
					'commercial_listings.lease_term_months',
					'commercial_listings.property_description',
					'commercial_listings.floor',
					'commercial_listings.sq_footage',
					'commercial_listings.favorites as c_favorites', 'commercial_listings.show as c_show',
					'commercial_listings.expose_address as c_expose_address',
					'units.id as unit_id',
					'units.primary_agent_id',
					'units.primary_agent2_id'
				)

				listings
			end

			def residential_search(company_id, search_params)
				listings = Unit
					.joins(:residential_listing, building: :neighborhood)
					.where('units.archived = false')
					.where('units.status IN (?)', Unit.statuses["active"])

				listings = _restrict_on_residential_model(company_id, search_params, listings)
				listings = _restrict_on_unit_model(company_id, search_params, listings)
				listings = _sort_by(search_params, listings)


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
					'neighborhoods.name as neighborhood_name',
					'neighborhoods.borough as neighborhood_borough',
					'residential_listings.id AS r_id',
					'residential_listings.lease_start', 'residential_listings.lease_end',
					'residential_listings.tp_fee_percentage', 'residential_listings.beds',
					'residential_listings.baths', 'residential_listings.description',
					'residential_listings.favorites as r_favorites', 'residential_listings.show as r_show',
					'residential_listings.expose_address as r_expose_address',
					'residential_listings.floor_number', 'residential_listings.total_room_count',
					'residential_listings.condition', 'residential_listings.showing_instruction',
					'residential_listings.commission_amount', 'residential_listings.cyof',
					'residential_listings.rented_date', 'residential_listings.rlsny',
					'residential_listings.share_with_brokers',
					'units.id as unit_id',
					'units.primary_agent_id',
					'units.primary_agent2_id',
					'residential_listings.id AS r_id',
				)

				listings
			end

			# TODO
			def sales_search(company_id, search_params)
				listings = ResidentialListing.none
			end

			def commercial_search(company_id, search_params)
				listings = Unit.joins(:commercial_listing, building: :neighborhood)
					.where('units.archived = false')
					.where('units.status IN (?)', Unit.statuses["active"])

				# TODO: restrict by commercial params
				listings = _restrict_on_unit_model(company_id, search_params, listings)
				listings = _sort_by(search_params, listings)

				listings = listings
					.select('units.building_unit', 'units.status', 'units.available_by',
					'units.listing_id', 'units.updated_at', 'units.rent',
					'buildings.administrative_area_level_2_short AS administrative_area_level_2_short',
					'buildings.administrative_area_level_1_short AS administrative_area_level_1_short',
					'buildings.sublocality',
					'buildings.street_number', 'buildings.route',
					'buildings.postal_code',
					'buildings.lat',
					'buildings.lng',
					'buildings.id as building_id',
					'neighborhoods.name as neighborhood_name',
					'neighborhoods.borough as neighborhood_borough',
					'units.id as unit_id',
					'commercial_listings.lease_term_months',
					'commercial_listings.property_description',
					'commercial_listings.floor',
					'commercial_listings.sq_footage',
					'commercial_listings.favorites as c_favorites', 'commercial_listings.show as c_show',
					'commercial_listings.expose_address as c_expose_address',
					'units.primary_agent_id',
					'units.primary_agent2_id',
					'commercial_listings.id as c_id',
				)

				listings
			end

			private

				def _search_by_bldg_amenity(feature, company_id, listings, search_params)
					if search_params[feature.to_sym] && !search_params[feature.to_sym].empty?
						feature_required = to_boolean(search_params[feature.to_sym])
						if !feature_required
							return listings
						end

						# some fields need to be tranlated into our terminology
						additonal_listings = []
						if feature == 'laundry_in_building'
							return _search_laundry_in_bldg(company_id, listings)
						end
						# make sure feature is all lowercase
						feature_record = BuildingAmenity.where(company_id: company_id, name: feature.downcase).first
						if feature_record
							listings = listings.joins(building: :building_amenities)
	  	    			.where('building_amenity_id = ?', feature_record.id)
	  	    	end
					end

					listings
				end

				def _search_laundry_in_bldg(company_id, listings)
					# make sure feature is all lowercase
					feature_record1 = ResidentialAmenity.where(company_id: company_id)
						.where('residential_amenities.name ILIKE ?', "%washer/dryer%").first
					if feature_record1
						unit_ids = listings.map(&:id)
				    listings1_ids = ResidentialListing.joins(:residential_amenities)
				    .where(unit_id: unit_ids)
				    .where('residential_amenity_id = ?', feature_record1.id)
				    .map{|r| r.unit_id}
  	    	end

  	    	feature_record2 = BuildingAmenity
  	    		.where(company_id: company_id).
  	    		where('name ILIKE ?', 'laundry in bldg').first
					if feature_record2
						listings2_ids = listings.joins(building: :building_amenities)
  	    			.where('building_amenity_id = ?', feature_record2.id).map(&:id)
  	    	end

  	    	new_ids = [listings1_ids, listings2_ids].flatten
  	    	listings = listings.where(id: new_ids)
  	     	listings
				end

				def _search_by_residential_amenity(feature, company_id, listings, search_params)
					if !search_params[feature.to_sym] || search_params[feature.to_sym].empty?
						return listings
					end
					feature_required = to_boolean(search_params[feature.to_sym])
					if !feature_required
						return listings
					end

					# some fields need to be tranlated into our terminology
					if feature == "laundry_in_unit"
						feature = "washer/dryer"
					end

					# make sure feature is all lowercase
					feature_record = ResidentialAmenity.where(company_id: company_id)
						.where('name ILIKE ?', "%#{feature.downcase}%").first
					if feature_record
						# listings is still a list of unit records
						unit_ids = listings.map(&:id)
				    restricted_unit_ids = ResidentialListing.joins(:residential_amenities)
				    .where(unit_id: unit_ids)
				    .where('residential_amenity_id = ?', feature_record.id)
				    .map{|r| r.unit_id}

						#listings = listings.joins(residential_listing: :residential_amenities)
  	    		#	.where('residential_amenity_id = ?', feature_record.id)
  	    		listings = listings.where(id: restricted_unit_ids)
  	    	end

					listings
				end

				# Filter our search by all fields relevent to the base Unit model:
				# rent, available_by
				def _restrict_on_unit_model(company_id, search_params, listings)
					# min rent
					if search_params[:min_rent] && !search_params[:min_rent].empty?
						listings = listings.where('rent > ?', search_params[:min_rent])
					end
					# max rent
					if search_params[:max_rent] && !search_params[:max_rent].empty?
						listings = listings.where('rent < ?', search_params[:max_rent])
					end
					# elevator
					listings = _search_by_bldg_amenity('elevator', company_id, listings, search_params)
					# # doorman
					listings = _search_by_bldg_amenity('doorman', company_id, listings, search_params)
					# TODO: more defensive parameter checking
					# date_available_before - YYYY-MM-DD
					if search_params[:date_available_before] && !search_params[:date_available_before].empty?
						available_by = Date::strptime(search_params[:date_available_before], "%Y-%m-%d")
						listings = listings.where('available_by < ?', search_params[:date_available_before])
					end
					# date_available_after - YYYY-MM-DD
					if search_params[:date_available_after] && !search_params[:date_available_after].empty?
						available_by = Date::strptime(search_params[:date_available_after], "%Y-%m-%d")
						listings = listings.where('available_by > ?', search_params[:date_available_after])
					end
					# laundry_in_building
					listings = _search_by_bldg_amenity('laundry_in_building', company_id, listings, search_params)

					if search_params[:has_photos] && (search_params[:has_photos] == "true" || search_params[:has_photos] == "1")
						#listings = listings.joins(unit: :images)
						listings = listings.joins(:images)
					end

					# neighborhoods
					if search_params[:neighborhoods] && !search_params[:neighborhoods].empty?
						neighborhood_ids = search_params[:neighborhoods].split(',')
						listings = listings
							.where('neighborhood_id IN (?)', neighborhood_ids)
					end

					# agents
					if search_params[:agents] && !search_params[:agents].empty?
						agent_ids = search_params[:agents].split(',')
						listings = listings.where('units.primary_agent_id in (?) OR units.primary_agent2_id in (?)', agent_ids, agent_ids)
					end

					# updated_at
					if search_params[:changed_at] && !search_params[:changed_at].empty?
						time = Time.parse(search_params[:changed_at]).in_time_zone
		        listings = listings.where('units.updated_at > ?', time);
		      end

					listings
				end

				# Filter our search by all fields relevent to the ResidentialListing model:
				def _restrict_on_residential_model(company_id, search_params, listings)
					# bedrooms
					listings = _restrict_layout(search_params[:layout], listings)
					# bathrooms
					listings = _restrict_bathrooms(search_params[:bathrooms], listings)
					# cats allowed
					if (search_params[:cats_allowed] && !search_params[:cats_allowed].empty?)
						cats_allowed = to_boolean(search_params[:cats_allowed])
						pet_policies = PetPolicy.policies_that_allow_cats(company_id, cats_allowed)
						listings = listings
						.where('buildings.pet_policy_id IN (?)', pet_policies.map(&:id));
					end
					# dogs allowed
					if (search_params[:dogs_allowed] && !search_params[:dogs_allowed].empty?)
						dogs_allowed = to_boolean(search_params[:dogs_allowed])
						pet_policies = PetPolicy.policies_that_allow_dogs(company_id, dogs_allowed)
						listings = listings
							.where('buildings.pet_policy_id IN (?)', pet_policies.map(&:id));
					end
					# laundry_in_unit
					listings = _search_by_residential_amenity('laundry_in_unit', company_id, listings, search_params)

					listings
				end

				def _sort_by(search_params, listings)
					return if !search_params[:sort_column] || search_params[:sort_column].empty?
					sort_column = search_params[:sort_column]

					sort_column = sort_column.downcase
					case(sort_column)
					when 'layout'
						sort_column = 'beds'
					when 'rent'
						sort_column = 'rent'
					when 'date_available'
						sort_column = 'units.available_by'
					when 'updated'
						sort_column = 'units.updated_at'
					when 'status_updated'
						# TODO: we don't explicitly support this. map to be the same as updated_at
						sort_column = 'units.updated_at'
					else
						sort_column = 'units.updated_at'
					end

					sort_order = search_params[:sort_dir]

					listings.order(sort_column + ' ' + sort_order)
				end

				def _restrict_layout(layout, listings)
					if (!layout || layout.empty?)
						return listings
					end

					if (!listings)
						raise "No listings supplied"
					end

					case(layout)
					when "10"
						listings = listings.where('residential_listings.beds = ?', 0)
					when "20"
						listings = listings.where('residential_listings.beds = ?', 1)
					when "30"
						listings = listings.where('residential_listings.beds = ?', 2)
					when "40"
						listings = listings.where('residential_listings.beds = ?', 3)
					when "50"
						listings = listings.where('residential_listings.beds > ?', 3)
					when "80"
						# loft
						# TODO: what the heck am I supposed to do with this?
					end

					listings
				end

				def _restrict_bathrooms(num_bathrooms, listings)
					# 10 - 1 B, 15 - 1.5 B, 20 - 2 B, 25 - 2.5 B, 30 - 3 B, 35 - 3.5+ B
					if (!num_bathrooms || num_bathrooms.empty?)
						return listings
					end

					if (!listings)
						raise "No listings supplied"
					end

					case(num_bathrooms)
					when "10"
						listings = listings.where('residential_listings.baths = ?', 1)
					when "15"
						listings = listings.where('residential_listings.baths = ?', 1.5)
					when "20"
						listings = listings.where('residential_listings.baths = ?', 2)
					when "25"
						listings = listings.where('residential_listings.baths = ?', 2.5)
					when "30"
						listings = listings.where('residential_listings.baths = ?', 3)
					when "35"
						listings = listings.where('residential_listings.baths > ?', 3)
					end

					listings
				end

		end
	end
end