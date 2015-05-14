class EmployeeTitle < ActiveRecord::Base
	has_many :users
	before_save :sanitize_name

  def sanitize_name
    name.downcase.gsub!(' ', '_')
  end

  def display_name
  	name.titleize.gsub('_', ' ')
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

end