module API
	module V1

		class AgentsController < ApplicationController
			skip_authorize_resource
			skip_before_action :logged_in_user
			protect_from_forgery with: :null_session
			before_action :authenticate

			# designed to match: http://developers.nestio.com/api/v1/

			# params: key (required)

			# response codes
			# 200 - success, 400 - invalid params, 403 - invalid API key

			# example request
			# https://nestiolistings.com/api/v1/public/agents/123/?key={API KEY}

			def index
				# pagination
				per_page = agent_params[:per_page].to_i
				if per_page
					if per_page < 0 || per_page > 50
						per_page = 50
					end
				end

				@agents = User.where(archived: false, company: @user.company).paginate(
				 	:page => agent_params[:page], :per_page => per_page)
			end

			def show
				@agent = User.find(params[:id])
				#render json: agent, status: 200
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

			def agent_params
				params.permit(:token, :pretty, :format, :per_page, :page)
			end
		
		end
	end
end