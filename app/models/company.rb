class Company < ActiveRecord::Base
	attachment :logo
	validates :name, presence: true, length: {maximum: 100}, 
						uniqueness: { case_sensitive: false }

	has_many :offices, :dependent => :destroy
	has_many :users
	accepts_nested_attributes_for :users
	has_many :buildings
	has_many :landlords

	attr_accessor :agent_types, :employee_titles

	validates :name, presence: true, length: {maximum: 50},
		uniqueness: { case_sensitive: false }

	# should we limit this to 1 per company?
	def admins
		@admins = self.users.select{|u| u if u.is_company_admin? }
	end

	def managers
		@managers = self.users.select{|u| u if u.is_manager? }
	end

	def update_agent_types
		self.agent_types.split(/\r?\n/).each {|a|
      @sanitized_name = AgentType.sanitize_name(a)
      AgentType.find_or_create_by(name: @sanitized_name)
    }
	end

	def update_employee_titles
		self.employee_titles.split(/\r?\n/).each {|e|
      @sanitized_name = EmployeeTitle.sanitize_name(e)
      EmployeeTitle.find_or_create_by(name: @sanitized_name)
    }
	end


end
