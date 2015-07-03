module UsersHelper

	def last_login(user)
		if !user.last_login_at
			return '-'
		else
			return local_time(user.last_login_at)
		end
	end


	def employee_title_and_specialty(user)
		html = user.employee_title.name.titleize
		if user.is_company_admin?
			html = html + ' <span class="glyphicon glyphicon-star dark-orange" aria-hidden="true"></span>'
		end
		
		if user.is_agent?
			html = html + ' | ' + user.agent_specialties.join(", ")
		end

		html.html_safe
	end

	
end
