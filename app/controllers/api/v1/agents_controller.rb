module API
	module V1

		class AgentsController < ApiController
			# designed to match: http://developers.nestio.com/api/v1/

			# params: token (required)

			# response codes
			# 200 - success, 400 - invalid params, 403 - invalid API key

			# example request
			# https://nestiolistings.com/api/v1/public/agents/123/?key={API KEY}

			def index
				# pagination
				per_page = 50
				if agent_params[:per_page] && !agent_params[:per_page].empty?
					per_page = agent_params[:per_page].to_i
					if per_page < 0 || per_page > 50
						per_page = 50
					end
				end

				@agents = User.unarchived.where(company: @user.company)
					.page(agent_params[:page]).per(per_page)
			end

			def show
				@agent = User.find(params[:id])
			end
		
		protected
			def agent_params
				params.permit(:token, :pretty, :format, :per_page, :page)
			end
		
		end
	end
end