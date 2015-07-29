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

				@agents = User.where(archived: false)
					.where(company: current_user.company)
					.joins(:employee_title)
					.select('users.name', 'users.email', 'users.id', 'users.phone_number',
						'users.updated_at', 'users.mobile_phone_number', 'users.bio',
						'employee_titles.name AS title')
				@agents = @agents.page(agent_params[:page]).per(per_page)

				# @images = Image.where(user_id: @agents.map(&:id))
				# @agents = User.search(params, current_user)
				# 	.page(agent_params[:page]).per(per_page)
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