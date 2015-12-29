module AnnouncementsHelper

	def trim_announcement text
		if !text.nil? && text.size > 70
			text[0..70] + '...'
		else
			text
		end
	end

end
