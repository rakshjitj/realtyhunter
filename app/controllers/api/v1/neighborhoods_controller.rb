module API
	module V1

		class NeighborhoodsController < ApplicationController
			include API::V1::NestioInterface
			skip_authorize_resource
			skip_before_action :logged_in_user
			protect_from_forgery with: :null_session
			before_action :authenticate

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
		
			def render_unauthorized
				self.headers['WWW-Authenticate'] = 'Token realm-"Agents"'

				respond_to do |format|
					format.json { render json: 'Bad credentials', status: 401 }
				end
			end

		protected
			def authenticate
				authenticate_token || render_unauthorized
			end

			def authenticate_token
				authed = false
				# check for token in the URL?
				if !authed && params[:token]
					@user = User.find_by(auth_token: params[:token])
					return @user ? true : false
				end

				authenticate_or_request_with_http_token('Agents') do |token, options|
					@user = User.find_by(auth_token: token)
					authed = true
				end
			end

			def neighborhood_params
				params.permit(:token, :pretty, :format, :per_page, :page, 
					:state, :city, :company_building_limit)
			end
		
		end
	end
end