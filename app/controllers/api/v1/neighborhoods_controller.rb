module API
	module V1

		class NeighborhoodsController < ApiController
			include API::V1::NestioInterface

			# designed to match: http://developers.nestio.com/api/v1/

			# params: token (required)

			# response codes
			# 200 - success, 400 - invalid params, 403 - invalid API key

			# example request
			# https://nestiolistings.com/api/v1/public/neighborhoods/?key={API KEY}

			# allowed params:
			# state (2 letter abbreviation), city, company_building_limit

			def index
				# pagination
				per_page = 50
				if neighborhood_params[:per_page] && !neighborhood_params[:per_page].empty?
					per_page = neighborhood_params[:per_page].to_i
					if per_page < 0 || per_page > 50
						per_page = 50
					end
				end

				# calls our API::V1::NestioInterface module located under /lib
				@neighborhoods = neighborhood_search(neighborhood_params)
				@neighborhoods = @neighborhoods.paginate(
				 	:page => neighborhood_params[:page], :per_page => per_page)
			end

			def show
				@neighborhood = Neighborhood.where(id: params[:id], archived: false).first
			end
		
		protected

			def neighborhood_params
				params.permit(:token, :pretty, :format, :per_page, :page, 
					:state, :city, :company_building_limit)
			end
		
		end
	end
end