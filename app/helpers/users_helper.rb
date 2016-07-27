module UsersHelper

	def last_login(user)
		if !user.last_login_at
			return '-'
		else
			return local_time(user.last_login_at)
		end
	end


	def employee_title_and_specialty(user)

		title = ''
		if user.respond_to?("employee_title_name".to_sym)
			title = user.employee_title_name.titleize
		else
			title = user.employee_title.name.titleize
		end

		html = title.titleize
		if user.employee_title_name == EmployeeTitle.company_admin
			html = html + ' <span class="glyphicon glyphicon-star dark-orange" aria-hidden="true"></span>'
		end

		html.html_safe
	end


end
