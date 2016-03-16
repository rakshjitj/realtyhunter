module API
	module V1

		class ListingsController < ApiController
			include API::V1::NestioInterface

			# designed to match: http://developers.nestio.com/api/v1/

			# params: token (required)

			# response codes
			# 200 - success, 403 - invalid API key

			# example request
			# https://nestiolistings.com/api/v1/public/listings/?layout=10&min_rent=1500&max_rent=2000&key={API KEY}

			def index
				restrict_results
			end

			def show
				# id in this case refers to the unit's listing id
				listings = all_listings_search(@user.company_id, {id: params[:id]})
				@pet_policies = Building.get_pet_policies(listings)
				@rental_terms = Building.get_rental_terms(@listings)
				@building_utilities = Building.get_utilities(@listings)
				@residential_amenities = ResidentialListing.get_amenities(listings)
				@images = Unit.get_all_images(listings)
				@primary_agents = Unit.get_primary_agents(listings)
				@building_amenities = Building.get_amenities(listings)

				if !listings.empty?
					render json: Listing.new({
						listing: listings[0],
						residential_amenities: @residential_amenities[listings[0].unit_id],
						pet_policies: @pet_policies[listings[0].building_id],
						rental_terms: @rental_terms[listings[0].building_id],
						building_utilities: @building_utilities[listings[0].building_id],
						primary_agents: @primary_agents[listings[0].unit_id],
						building_amenities: @building_amenities[listings[0].building_id],
						images: @images[listings[0].unit_id]
						})
				else
					render json: {}
				end
			end

		protected

			def _is_valid_bool_value(val)
				val = %w[true false 0 1].include?(val) ? val : ""
			end

			# set some reasonable defaults for the search params,
			# do some data validation on parameters
			def restrict_results
				# 10 = residential, 20 = sales, 30 = commercial
				# default to residential
				@listing_type = %w[10 20 30].include?(listing_params[:listing_type]) ? listing_params[:listing_type] : ""
				# 10 - studio, 20 - 1 BR, 30 - 2 BR, 40 - 3 BR, 50 - 4+ BR, 80 - LOFT
				layout = %w[10 20 30 40 50 80].include?(listing_params[:layout]) ? listing_params[:layout] : ""
				# 10 - 1 B, 15 - 1.5 B, 20 - 2 B, 25 - 2.5 B, 30 - 3 B, 35 - 3.5+ B
				bathrooms = %w[10 15 20 25 30 35].include?(listing_params[:bathrooms]) ? listing_params[:bathrooms] : ""
				# cats allowed
				cats_allowed = _is_valid_bool_value(listing_params[:cats_allowed])
				# dogs allowed
				dogs_allowed = _is_valid_bool_value(listing_params[:dogs_allowed])
				# elevator
				elevator = _is_valid_bool_value(listing_params[:elevator])
				# doorman
				doorman = _is_valid_bool_value(listing_params[:doorman])
				# laundry in building
				laundry_in_building = _is_valid_bool_value(listing_params[:laundry_in_building])
				# laundry in unit
				laundry_in_unit = _is_valid_bool_value(listing_params[:laundry_in_unit])
				# has_photos
				has_photos = _is_valid_bool_value(listing_params[:has_photos])
				# sort order defaults to order by last udpated
				sort_column = %w[layout rent date_available updated status_updated].include?(listing_params[:sort]) ? listing_params[:sort] : "updated"
				# sort_dir
				sort_dir = %w[asc desc].include?(listing_params[:sort_dir]) ? listing_params[:sort_dir] : ""
				# pagination
				per_page = 50
				if listing_params[:per_page] && !listing_params[:per_page].empty?
					per_page = listing_params[:per_page].to_i
					if per_page < 50
						per_page = 50
					end
					if per_page > 500
						per_page = 500
					end
				end

				# calls our API::V1::NestioInterface module located under /lib
				search_params = {
					listing_type: @listing_type,
					layout: layout,
					bathrooms: bathrooms,
					min_rent: listing_params[:min_rent],
					max_rent: listing_params[:max_rent],
					cats_allowed: cats_allowed,
					dogs_allowed: dogs_allowed,
					elevator: elevator,
					doorman: doorman,
					date_available_before: listing_params[:date_available_before],
					date_available_after: listing_params[:date_available_after],
					laundry_in_building: laundry_in_building,
					laundry_in_unit: laundry_in_unit,
					has_photos: has_photos,
					sort_column: sort_column,
					sort_dir: sort_dir,
					per_page: per_page,
					page: listing_params[:page],
					agents: listing_params[:agents],
					neighborhoods: listing_params[:neighborhoods],
					changed_at: listing_params[:changed_at]
				}

				search_type_breakdown(search_params)
				@listing_type = @listing_type.to_i
			end

			def search_type_breakdown(search_params)
				@residential_amenities = []
				@pet_policies = []
				@rental_terms = []
				@building_utilities = []

				if search_params[:listing_type] == "10" # residential
					@listings = residential_search(@user.company_id, search_params)
					@listings = @listings.page(listing_params[:page]).per(listing_params[:per_page])
					@pet_policies = Building.get_pet_policies(@listings)
					@rental_terms = Building.get_rental_terms(@listings)
					@building_utilities = Building.get_utilities(@listings)
					@residential_amenities = ResidentialListing.get_amenities(@listings)

				# sales
				elsif search_params[:listing_type] == "20" # sales
					@listings = sales_search(@user.company_id, search_params)
					@listings = @listings.page(listing_params[:page]).per(listing_params[:per_page])

				# commercial
				elsif search_params[:listing_type] == "30" #commercial
					@listings = commercial_search(@user.company_id, search_params)
					@listings = @listings.page(listing_params[:page]).per(listing_params[:per_page])

				else
					@listings = all_listings_search(@user.company_id, search_params)
					@listings = @listings.page(listing_params[:page]).per(listing_params[:per_page])
					@residential_amenities = ResidentialListing.get_amenities(@listings)
					@pet_policies = Building.get_pet_policies(@listings)
					@rental_terms = Building.get_rental_terms(@listings)
					@building_utilities = Building.get_utilities(@listings)

				end

				@images = Unit.get_all_images(@listings)
				@primary_agents = Unit.get_primary_agents(@listings)
				@building_amenities = Building.get_amenities(@listings)
				# repackage into a format that's easily digestible
				# by our API renderer
				output = @listings.map do |l|
					Listing.new({
						listing: l,
						residential_amenities: @residential_amenities[l.unit_id],
						pet_policies: @pet_policies[l.building_id],
						rental_terms: @rental_terms[l.building_id],
						building_utilities: @building_utilities[l.building_id],
						primary_agents: @primary_agents[l.unit_id],
						building_amenities: @building_amenities[l.building_id],
						images: @images[l.unit_id]
						})
				end

				@lb = ListingBlob.new({
					items: output,
					total_count: @listings.total_count,
					total_pages: @listings.total_pages,
					page: @listings.current_page
					})
				render json: @lb
			end

			# Never trust parameters from the scary internet, only allow the white list through.
    	def listing_params
	      params.permit(:token, :pretty, :format,
	      	:listing_type, :layout, :bathrooms, :min_rent, :max_rent,
	      	:cats_allowed, :dogs_allowed, :elevator, :doorman, :date_available_after,
	      	:date_available_before, :laundry_in_building, :laundry_in_unit, :changed_at,
	      	:has_photos, :featured, :sort, :sort_dir, :per_page, :page,
	      	:neighborhoods, :geometry, :agents)
    	end

		end
	end
end
