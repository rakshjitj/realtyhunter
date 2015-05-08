module UsersHelper

	def avatar_for(user)
		if user.avatar_key?
			image_tag(user.avatar_url, alt: user.name + ' avatar', class: "gravatar")
		else
			#return "<span class=\"fa-stack fa-fw user-avatar pull-right\">
			#  <i class=\"fa fa-square-o fa-stack-2x\"></i>
			#  <i class=\"fa fa-user fa-stack-1x\"></i>
			#</span>".html_safe
			return "<i class=\"fa fa-user fa-fw fa-border pull-right user-avatar\"></i>".html_safe
		end
	end

	def avatar_thumbnail_for(user)
		if user.avatar_key?
			#thumbnail_url = S3_AVATAR_THUMBNAIL_BUCKET.objects[user.avatar_key].url_for(:read)
			#image_tag(thumbnail_url, alt: user.name + ' avatar thumbnail', class: "gravatar")
			image_tag(user.avatar_thumbnail_url, alt: user.name + ' avatar thumbnail', class: "gravatar")
		else 
			# TODO: render default 'no profile pic chosen'
			'<span class="icon-avatar-thumbnail"></span>'
		end
	end

	# Returns the Gravatar for the given user.
  #def gravatar_for(user, options = { size: 80 })
  #	if user.email
	#    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
	#    size = options[:size]
	#    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
	#    image_tag(gravatar_url, alt: user.name, class: "gravatar")
	#  end
  #end

end
