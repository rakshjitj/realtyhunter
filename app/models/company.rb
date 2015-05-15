class Company < ActiveRecord::Base
	attachment :logo
	has_many :offices
	has_many :users
	
	validates :name, presence: true, length: {maximum: 50},
		uniqueness: { case_sensitive: false }

	def admins
		@admins = self.users.select{|u| u if u.is_company_admin? }
	end

	def managers
		@managers = self.users.select{|u| u if u.is_manager? }
	end
end
