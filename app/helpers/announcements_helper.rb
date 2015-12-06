module AnnouncementsHelper

	def trim_announcement text
		if !text.nil? && text.size > 75
			text[0..75] + '...'
		else
			text
		end
	end

end
