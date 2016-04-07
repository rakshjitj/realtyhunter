module API
	module V1

		class ApiController < ApplicationController
			skip_authorize_resource
			skip_before_action :logged_in_user
			protect_from_forgery with: :null_session
			before_action :authenticate

			def render_unauthorized
				self.headers['WWW-Authenticate'] = 'Token realm-"Agents"'

				respond_to do |format|
					format.json { render json: 'Bad credentials', status: 403 }
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
					@user = User.where(auth_token: params[:token]).first
					return @user ? true : false
				end

				authenticate_or_request_with_http_token('Agents') do |token, options|
					@user = User.where(auth_token: token).first
					authed = true
				end
			end

			# def api_params
			# 	params.permit(:token, :pretty, :format)
			# end

		end
	end
end
