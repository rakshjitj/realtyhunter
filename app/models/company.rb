class Company < ActiveRecord::Base
	attachment :logo
	has_many :offices, :dependent => :destroy
	has_many :users
	accepts_nested_attributes_for :users
	
	validates :name, presence: true, length: {maximum: 50},
		uniqueness: { case_sensitive: false }

	# should we limit this to 1 per company?
	def admins
		@admins = self.users.select{|u| u if u.is_company_admin? }
	end

	def managers
		@managers = self.users.select{|u| u if u.is_manager? }
	end
end
