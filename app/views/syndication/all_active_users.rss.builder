xml.instruct! :xml, :version => "1.0"
xml.agents do
	@users.each do |user|
		if user.is_special_agent? || user.is_streeteasy_agent?
			xml.agent do
				xml.name user.name
				xml.id user.id
				xml.email user.email
				xml.streeteasy_email user.streeteasy_email
				xml.mobile user.mobile_phone_number
				xml.streeteasy_mobile user.streeteasy_mobile_number
				xml.short_bio user.bio
				if user.agent_hide == true
					xml.display_on_website
				end
				xml.office user.office.name
				xml.job_title user.employee_title.name
				if !user.specialties.blank?
					xml.user_specialties user.specialties.map(&:name).join(',')
				end
				if !user.roles.blank?
					xml.permissions user.roles.map(&:name).join(',')
				end
			end
		end
	end
end