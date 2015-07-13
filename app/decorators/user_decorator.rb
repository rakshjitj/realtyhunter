class UserDecorator 
	attr_reader :user

	def initialize(user)
		@user = user
	end

	def method_missing(method_name, *args, &block)
		user.send(method_name, *args, &block)
	end

	def respond_to_missing?(method_name, include_private = false)
		user.respond_to?(method_name, include_private) || super
	end

	# extract presentation logic

end