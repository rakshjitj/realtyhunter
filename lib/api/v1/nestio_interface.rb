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

			# General search function, called by our external API.
			# Can handle any and all search params supported by Nestio's API:
			# http://developers.nestio.com/api/v1/
			def search(company_id, search_params)

				listings = Unit.joins(:building)
					.where(archived: false)
					.where('buildings.company_id = ?', @user.company_id)

				listings = _restrict_on_unit_model(search_params, listings)

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
				# Filter our search by all fields relevent to the base Unit model:
				# rent, available_by			
				def _restrict_on_unit_model(search_params, listings)
					if search_params[:min_rent] && !search_params[:min_rent].empty?

						listings = listings.where('rent > ?', search_params[:min_rent])
					end

					if search_params[:max_rent] && !search_params[:max_rent].empty?
						listings = listings.where('rent < ?', search_params[:max_rent])
					end
				
					# TODO: more defensive parameter checking
					# YYYY-MM-DD
					if search_params[:date_available_before] && !search_params[:date_available_before].empty?
						listings = listings.where('available_by < ?', search_params[:date_available_before])
					end
				
					# YYYY-MM-DD
					if search_params[:date_available_after] && !search_params[:date_available_after].empty?
						listings = listings.where('available_by > ?', search_params[:date_available_after])
					end
			
					listings
				end

				# Filter our search by all fields relevent to the ResidentialUnit model:
				# beds, baths
				def _restrict_on_residential_model(company_id, search_params, listings)
					listings = listings.where("actable_type = 'ResidentialUnit'")

				 	listings = Unit.get_residential(listings).paginate(
				 		:page => search_params[:page], :per_page => search_params[:per_page])

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

					listings
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