class Company < ActiveRecord::Base
	attachment :logo
	validates :name, presence: true, length: {maximum: 100}, 
						uniqueness: { case_sensitive: false }

	has_many :offices, :dependent => :destroy
	has_many :users
	accepts_nested_attributes_for :users
	has_many :buildings
	has_many :landlords
	has_many :building_amenities
	has_many :rental_terms

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

	def self.create_with_environment(params)
		# create default set of employee titles
		# create default set of agent specializations

		# create default set of building amenities
		@company = Company.create(params)
		BuildingAmenity.create([
			{name: "Gym/atheletic facility", company: @company},
			{name: "Sauna", company: @company},
			{name: "Doorman", company: @company},
			{name: "Laundry in bldg", company: @company},
			{name: "Bike room", company: @company},
			{name: "Brownstone", company: @company},
			{name: "Roof deck", company: @company},
			{name: "Garage parking", company: @company}
		])

		RentalTerm.create([
			{name: "Heat included", company: @company},
			{name: "Hot water included", company: @company},
			{name: "Heat/hot water included", company: @company},
			{name: "Gas included", company: @company},
			{name: "Electric included", company: @company},
			{name: "Cable included", company: @company},
			{name: "Internet included", company: @company},
			{name: "All utils included", company: @company},
			{name: "No utils included", company: @company},
			{name: "Water not included", company: @company},
			{name: "Trash not included", company: @company},
		])
		@company
	end
end
