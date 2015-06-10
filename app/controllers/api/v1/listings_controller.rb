module API
	module V1

		class ListingsController < ApplicationController
			skip_authorize_resource
			skip_before_action :logged_in_user
			protect_from_forgery with: :null_session
			before_action :authenticate

			# designed to match: http://developers.nestio.com/api/v1/

			# params: key (required)

			# response codes
			# 200 - success, 400 - invalid params, 403 - invalid API key

			# example request
			# https://nestiolistings.com/api/v1/public/listings/?layout=10&min_rent=1500&max_rent=2000&key={API KEY}

			def index
				listings = Unit.joins(:building)
					.where(archived: false)
					.where('buildings.company_id = ?', @user.company.id)
					.where("actable_type = 'ResidentialUnit'")

				#@users.paginate(:page => params[:page], :per_page => 50).order("created_at ASC")
				@listings = Unit.get_residential(listings).paginate(:page => params[:page], :per_page => 50)
			end

			def show
				@listing = ResidentialUnit.find(params[:id])
			end
		
			# TODO: pull out into common methods
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
		
		end
	end
end