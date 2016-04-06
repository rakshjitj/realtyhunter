class EmployeeTitle < ActiveRecord::Base
	has_many :users
	before_save :sanitize_name

  def sanitize_name
    name.downcase
  end

  def self.sanitize_name(str)
    return str.downcase
  end

  def display_name
  	name.titleize.tr('_', ' ')
  end

  def self.agent
		@agent_title = EmployeeTitle.where(name: "agent").first;
		if !@agent_title
			@agent_title = EmployeeTitle.create(name: "agent")
		end

		@agent_title
	end

	def self.broker
		@agent_title = EmployeeTitle.where(name: "broker").first;
		if !@agent_title
			@agent_title = EmployeeTitle.create(name: "broker")
		end

		@agent_title
	end

	def self.manager
		@agent_title = EmployeeTitle.where(name: "manager").first;
		if !@agent_title
			@agent_title = EmployeeTitle.create(name: "manager")
		end

		@agent_title
	end

	def self.closing_manager
		@agent_title = EmployeeTitle.where(name: "closing manager").first;
		if !@agent_title
			@agent_title = EmployeeTitle.create(name: "closing manager")
		end

		@agent_title
	end

	def self.company_admin
		@agent_title = EmployeeTitle.where(name: "company admin").first;
		if !@agent_title
			@agent_title = EmployeeTitle.create(name: "company admin")
		end

		@agent_title
	end

	def self.external_vendor
		@agent_title = EmployeeTitle.where(name: "external vendor").first;
		if !@agent_title
			@agent_title = EmployeeTitle.create(name: "external vendor")
		end

		@agent_title
	end

	def self.data_entry
		@agent_title = EmployeeTitle.where(name: "data entry").first;
		if !@agent_title
			@agent_title = EmployeeTitle.create(name: "data entry")
		end

		@agent_title
	end

end
