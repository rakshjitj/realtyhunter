module API
	module V1

		class AgentsController < ApplicationController
			skip_before_action :logged_in_user
			protect_from_forgery with: :null_session

			# designed to match: http://developers.nestio.com/api/v1/

			# params: key (required)

			# response codes
			# 200 - success, 400 - invalid params, 403 - invalid API key

			# example request
			# https://nestiolistings.com/api/v1/public/agents/123/?key={API KEY}

			def index
				agents = User.all
				render json: agents, status: 200
			end

			def show
				agent = User.find(params[:id])
				render json: agent, status: 200
			end
		end

	end
end