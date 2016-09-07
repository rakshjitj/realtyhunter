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
				listings = all_listings_search(@user.company_id, {id: params[:id], status: 'active,pending'})
				if listings && listings.length == 0
					render json: {}
				else
					listing = listings[0]
					pet_policies = Building.get_pet_policies(listings)
					rental_terms = Building.get_rental_terms(listings)
					building_utilities = Building.get_utilities(listings)
					residential_amenities = ResidentialListing.get_amenities(listings)
					images = Unit.get_all_images(listings)
					primary_agents = Unit.get_primary_agents(listings)
					open_houses = Unit.get_open_houses(listings)

					buildings = buildings_search({id: listing.building_id})
	        bldg_images = Building.get_all_bldg_images(buildings)
	        building_amenities = Building.get_amenities(buildings)

					serializer_params = {
						listing: listings[0],
						residential_amenities: residential_amenities[listing.unit_id],
						pet_policies: pet_policies[listing.building_id],
						rental_terms: rental_terms[listing.building_id],
						building_utilities: building_utilities[listing.building_id],
						primary_agents: primary_agents[listing.unit_id],
						images: images[listing.unit_id],
						open_houses: open_houses[listing.unit_id],
						building_blob: APIBuilding.new({
	            building: buildings[0],
	            images: images[buildings[0].building_id],
	            amenities: building_amenities[buildings[0].building_id]
	          })
					}

					if is_residential(listings[0])
						render json: APIResidentialListing.new(serializer_params)
					elsif is_commercial(listings[0])
						render json: APICommercialListing.new(serializer_params)
					elsif is_sales(listings[0])
						render json: APISalesListing.new(serializer_params)
					end
				end
			end

		protected

			def _is_valid_bool_value(val)
				val = %w[true false 0 1].include?(val) ? val : "".freeze
			end

			# set some reasonable defaults for the search params,
			# do some data validation on parameters
			def restrict_results
				# 10 = residential, 20 = sales, 30 = commercial
				# default to residential
				@listing_type = %w[10 20 30].include?(listing_params[:listing_type]) ? listing_params[:listing_type] : "".freeze
				# 10 - studio, 20 - 1 BR, 30 - 2 BR, 40 - 3 BR, 50 - 4+ BR, 80 - LOFT
				layout = %w[10 20 30 40 50 80].include?(listing_params[:layout]) ? listing_params[:layout] : "".freeze
				# 10 - 1 B, 15 - 1.5 B, 20 - 2 B, 25 - 2.5 B, 30 - 3 B, 35 - 3.5+ B
				bathrooms = %w[10 15 20 25 30 35].include?(listing_params[:bathrooms]) ? listing_params[:bathrooms] : "".freeze
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
				#status
				status = listing_params[:status] ? listing_params[:status] : 'active,pending'
				# sort order defaults to order by last udpated
				sort_column = %w[layout rent date_available updated status_updated].include?(listing_params[:sort]) ? listing_params[:sort] : "updated".freeze
				# sort_dir
				sort_dir = %w[asc desc].include?(listing_params[:sort_dir]) ? listing_params[:sort_dir] : "".freeze
				# pagination
				per_page = 50
				# if listing_params[:per_page] && !listing_params[:per_page].empty?
				# 	per_page = listing_params[:per_page].to_i
				# 	if per_page < 50
				# 		per_page = 50
				# 	end
				# 	if per_page > 50
				# 		per_page = 50
				# 	end
				# end

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
					changed_at: listing_params[:changed_at],
					status: status
				}

				search_type_breakdown(search_params)
				@listing_type = @listing_type.to_i
			end

			def search_type_breakdown(search_params)
				@residential_amenities = []
				@pet_policies = []
				@rental_terms = []
				@building_utilities = []
				@open_houses = []

				# residential
				if search_params[:listing_type] == "10".freeze
					listings = residential_search(@user.company_id, search_params)
				# sales
				elsif search_params[:listing_type] == "20".freeze
					listings = sales_search(@user.company_id, search_params)
				# commercial
				elsif search_params[:listing_type] == "30".freeze
					listings = commercial_search(@user.company_id, search_params)
				else # everything
					listings = all_listings_search(@user.company_id, search_params)
				end

				listings = listings.page(listing_params[:page]).per(listing_params[:per_page])

				# if cached, render cached blob

				# blob_cache_key = "api_v1_listings/#{@listings.pluck('units.id').join('')}-#{@listings.count}-#{@listings.maximum(:updated_at).to_i}"
				# blob = Rails.cache.fetch(blob_cache_key)
				# if blob
				# 	render json: blob
				# else
					if search_params[:listing_type] == "10".freeze # residential
						@pet_policies = Building.get_pet_policies(listings)
						@rental_terms = Building.get_rental_terms(listings)
						@building_utilities = Building.get_utilities(listings)
						@residential_amenities = ResidentialListing.get_amenities(listings)
					elsif search_params[:listing_type] == "20".freeze # sales
					elsif search_params[:listing_type] == "30".freeze #commercial
					else
						@residential_amenities = ResidentialListing.get_amenities(listings)
						@pet_policies = Building.get_pet_policies(listings)
						@rental_terms = Building.get_rental_terms(listings)
						@building_utilities = Building.get_utilities(listings)
					end

					@images = Unit.get_all_images(listings) || []
					@primary_agents = Unit.get_primary_agents(listings) || []
					@open_houses = Unit.get_open_houses(listings) || []

					# repackage into a format that's easily digestible
					# by our API renderer
					r_count = 0
					c_count = 0
					s_count = 0

					buildings = buildings_search({ids: listings.pluck(:building_id)})
					bldg_images = Building.get_all_bldg_images(buildings)
          building_amenities = Building.get_amenities(buildings)

          if !bldg_images
          	puts "\n\n\n******** NO BLDG IMAGES FOUND #{buildings.inspect}"
          end

          buildings = buildings.to_a.group_by(&:building_id)

					output = listings.map do |l|
						serializer_params = {
							listing: l,
							residential_amenities: @residential_amenities[l.unit_id],
							pet_policies: @pet_policies[l.building_id],
							rental_terms: @rental_terms[l.building_id],
							building_utilities: @building_utilities[l.building_id],
							primary_agents: @primary_agents[l.unit_id],
							images: @images[l.unit_id],
							open_houses: @open_houses[l.unit_id],
							building_blob:
								APIBuilding.new({
			            building: buildings[l.building_id][0],
			            images: 	bldg_images[l.building_id],
			            amenities: building_amenities[l.building_id]
			          })
						}

						if is_residential(l)
							r_count += 1
							APIResidentialListing.new(serializer_params)
						elsif is_commercial(l)
							c_count += 1
							APICommercialListing.new(serializer_params)
						elsif is_sales(l)
							s_count += 1
							#puts "---SALES #{l.inspect}"
							APISalesListing.new(serializer_params)
						else
							# Remove any that fall into this category - most likely leftovers from early testing,
							# bad code, etc.
							puts "AH HA FOUND ONE! #{l.listing_id}"
							#Unit.where(listing_id: l.listing_id).delete_all
						end
					end

					#puts "\n\n\n******* #{r_count} #{c_count} #{s_count} #{@listings.total_count}"

					blob = #Rails.cache.fetch(blob_cache_key, expires_in: 12.hours) do
						ListingBlob.new({
							items: output,
							total_count: listings.total_count,
							total_pages: listings.total_pages,
							page: listings.current_page
							})
					#end
					render json: blob
				#end
			end

			# Never trust parameters from the scary internet, only allow the white list through.
    	def listing_params
	      params.permit(:token, :pretty, :format,
	      	:listing_type, :layout, :bathrooms, :min_rent, :max_rent,
	      	:cats_allowed, :dogs_allowed, :elevator, :doorman, :date_available_after,
	      	:date_available_before, :laundry_in_building, :laundry_in_unit, :changed_at,
	      	:has_photos, :featured, :sort, :sort_dir, :per_page, :page,
	      	:neighborhoods, :geometry, :agents, :status)
    	end

		private
			def is_residential(object)
		    object.respond_to?(:r_id) && object.r_id
		  end

		  def is_commercial(object)
		    object.respond_to?(:c_id) && object.c_id
		  end

		  def is_sales(object)
		    object.respond_to?(:s_id) && object.s_id
		  end

		end
	end
end
