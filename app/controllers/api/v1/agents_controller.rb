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
					if per_page < 50
						per_page = 50
					end
					if per_page > 500
						per_page = 500
					end
				end

				@agents = User.unarchived
					.where(company: @user.company)
					.joins(:employee_title)
					.select('users.name', 'users.email', 'users.id', 'users.phone_number',
						'users.updated_at', 'users.mobile_phone_number', 'users.bio', 'users.updated_at',
						'employee_titles.name AS title')
					.includes(:image)


				@agents = @agents.where('employee_titles.name = ?', EmployeeTitle.agent.name)
				if stale?(@agents)
					# updated_at
					if agent_params[:changed_at] && !agent_params[:changed_at].empty?
						time = Time.parse(agent_params[:changed_at]).in_time_zone
		        @agents = @agents.where('users.updated_at > ?', time);
		      end

		      @agents = @agents.order("users.name ASC")
					@agents = @agents.page(agent_params[:page]).per(per_page)

					agents_arr = @agents.to_a
					#blob_cache_key = "api_v1_agents/#{agents_arr.map(&:id).join('')}-#{agents_arr.count}-#{@agents.maximum(:updated_at).to_i}"
					blob = #Rails.cache.fetch(blob_cache_key) do
						AgentBlob.new({users: @agents})
					#end
					render json: blob
				end
			end

			def show
				@agent = User.find(params[:id])
				render json: @agent
			end

		protected
			def agent_params
				params.permit(:token, :pretty, :updated_at, :format, :per_page, :page, :changed_at)
			end

		end
	end
end
