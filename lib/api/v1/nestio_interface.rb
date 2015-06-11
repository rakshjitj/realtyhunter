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

			# General search function, called by our external API.
			# Can handle any and all search params supported by Nestio's API:
			# http://developers.nestio.com/api/v1/
			def listing_search(company_id, search_params)

				listings = Unit.joins(:building)
					.where(archived: false)
					.where('buildings.company_id = ?', @user.company_id)

				listings = _restrict_on_unit_model(company_id, search_params, listings)

				# restrict by listing type. handle specific search parameters

				if search_params[:listing_type] == "10" # residential
					listings = _restrict_on_residential_model(company_id, search_params, listings)

				elsif search_params[:listing_type] == "20" # sales
					# TODO

				elsif search_params[:listing_type] == "30" # commercial
					listings = listings.where("actable_type = 'CommercialUnit'")
				 	listings = Unit.get_commercial(listings).paginate(
				 		:page => search_params[:page], :per_page => search_params[:per_page])
				end
			
				listings
			end

			private

				def _search_by_bldg_amenity(feature, company_id, listings, search_params)
					if search_params[feature.to_sym] && !search_params[feature.to_sym].empty?
						feature_required = to_boolean(search_params[feature.to_sym])
						if (feature_required)
							# some fields need to be tranlated into our terminology
							if feature == 'laundry_in_building'
								feature = "laundry in bldg"
							end
							# make sure feature is all lowercase
							feature_record = BuildingAmenity.where(company_id: company_id, name: feature.downcase).first
							if feature_record
								listings = listings.joins(building: :building_amenities)
  	  	    			.where('building_amenity_id = ?', feature_record.id)
  	  	    	end
    	    	end
					end
					listings
				end

				def _search_by_residential_amenity(feature, company_id, listings, search_params)
					if search_params[feature.to_sym] && !search_params[feature.to_sym].empty?
						feature_required = to_boolean(search_params[feature.to_sym])
						if (feature_required)
							# some fields need to be tranlated into our terminology
							if feature == 'laundry_in_unit'
								feature = "washer/dryer in unit"
							end
							# make sure feature is all lowercase
							feature_record = ResidentialAmenity.where(company_id: company_id, name: feature.downcase).first
							if feature_record
								listings = listings.joins(:residential_amenities)
  	  	    			.where('residential_amenity_id = ?', feature_record.id)
  	  	    	end
    	    	end
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
					# doorman
					listings = _search_by_bldg_amenity('doorman', company_id, listings, search_params)
					# TODO: more defensive parameter checking
					# date_available_before - YYYY-MM-DD
					if search_params[:date_available_before] && !search_params[:date_available_before].empty?
						listings = listings.where('available_by < ?', search_params[:date_available_before])
					end
					# date_available_after - YYYY-MM-DD
					if search_params[:date_available_after] && !search_params[:date_available_after].empty?
						listings = listings.where('available_by > ?', search_params[:date_available_after])
					end
					# laundry_in_building
					listings = _search_by_bldg_amenity('laundry_in_building', company_id, listings, search_params)
					
					# TODO: has_photos, featured, geometry

					# agents
					if search_params[:agents] && !search_params[:agents].empty?
						agent_ids = search_params[:agents].split(',')
						listings = listings.where(user_id: agent_ids)
					end

					# neighborhoods
					if search_params[:neighborhoods] && !search_params[:neighborhoods].empty?
						neighborhood_ids = search_params[:neighborhoods].split(',')
						listings = listings.joins(:building).where('neighborhood_id IN (?)', neighborhood_ids)
					end			

					listings
				end

				# Filter our search by all fields relevent to the ResidentialUnit model:
				# beds, baths
				def _restrict_on_residential_model(company_id, search_params, listings)
					listings = listings.where("actable_type = 'ResidentialUnit'")

				 	listings = Unit.get_residential(listings)#.paginate(
				 		#:page => search_params[:page], :per_page => search_params[:per_page])

					# enforce params that only make sense for residential
					# bedrooms
					listings = _restrict_layout(search_params[:layout], listings)
					# bathrooms
					listings = _restrict_bathrooms(search_params[:bathrooms], listings)

					# cats allowed
					if (search_params[:cats_allowed] && !search_params[:cats_allowed].empty?)
						cats_allowed = to_boolean(search_params[:cats_allowed])
						pet_policies = PetPolicy.policies_that_allow_cats(company_id, cats_allowed)
						listings = listings.where(pet_policy_id: pet_policies.map(&:id));
					end

					# dogs allowed
					if (search_params[:dogs_allowed] && !search_params[:dogs_allowed].empty?)
						dogs_allowed = to_boolean(search_params[:dogs_allowed])
						pet_policies = PetPolicy.policies_that_allow_dogs(company_id, dogs_allowed)
						listings = listings.where(pet_policy_id: pet_policies.map(&:id));
					end

					# laundry_in_unit
					listings = _search_by_residential_amenity('laundry_in_unit', company_id, listings, search_params)
					listings = _sort_residential_by(search_params, listings)

					listings.paginate(
				 		:page => search_params[:page], :per_page => search_params[:per_page])
				end

				def _sort_residential_by(search_params, listings)
					sort_column = search_params[:sort]
					return if sort_column.empty?

					sort_column = sort_column.downcase
					case(sort_column)
					when 'layout'
						sort_column = 'beds'
					when 'date_available'
						sort_column = 'available_by'
					when 'updated'
						sort_column = 'updated_at'
					when 'status_updated'
						# TODO: we don't explicitly support this. map to be the same as updated_at
						sort_column = 'updated_at'
					end

					if (search_params[:sort_dir].downcase != 'desc')
						listings = listings.sort_by{|l| l.send(sort_column)}
					else
						listings = listings.sort_by{|l| l.send(sort_column)}.reverse
					end
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
						listings = listings.where(beds: 0)
					when "20"
						listings = listings.where(beds: 1)
					when "30"
						listings = listings.where(beds: 2)
					when "40"
						listings = listings.where(beds: 3)
					when "50"
						listings = listings.where('beds > 3')
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
						listings = listings.where(baths: 1)
					when "15"
						listings = listings.where(baths: 1.5)
					when "20"
						listings = listings.where(baths: 2)
					when "25"
						listings = listings.where(baths: 2.5)
					when "30"
						listings = listings.where(baths: 3)
					when "35"
						listings = listings.where('baths > 3')
					end

					listings
				end

		end		
	end
end