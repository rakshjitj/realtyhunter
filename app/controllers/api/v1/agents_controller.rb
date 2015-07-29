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
					if per_page < 0 || per_page > 500
						per_page = 500
					end
				end

				#if !params[:changed_at]
					@agents = User.search(params, current_user)#unarchived.where(company: @user.company)
						.page(agent_params[:page]).per(per_page)
				#else
				# 	@agents = User.search(params)
				# 		.where('updated_at > ?', params[:changed_at])
				# 		.page(agent_params[:page]).per(per_page)
				# end
			end

			def show
				@agent = User.find(params[:id])
			end
		
		protected
			def agent_params
				params.permit(:token, :pretty, :format, :per_page, :page, :changed_at)
			end
		
		end
	end
end