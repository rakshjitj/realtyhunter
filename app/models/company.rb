class Company < ActiveRecord::Base
	attachment :logo
	validates :name, presence: true, length: {maximum: 100}, 
						uniqueness: { case_sensitive: false }

	has_many :offices, :dependent => :destroy
	has_many :users, dependent: :destroy
	accepts_nested_attributes_for :users
	has_many :buildings, dependent: :destroy
	has_many :landlords, dependent: :destroy
	has_many :building_amenities, dependent: :destroy
	has_many :rental_terms, dependent: :destroy
	has_many :required_securities, dependent: :destroy
	has_many :pet_policies, dependent: :destroy
	has_many :residential_amenities, dependent: :destroy
	has_many :commercial_property_types
	
	attr_accessor :agent_types, :employee_titles

	validates :name, presence: true, length: {maximum: 50},
		uniqueness: { case_sensitive: false }

  def archive
    self.archived = true
    self.save
  end

  def self.find_unarchived(id)
    find_by!(id: id, archived: false)
  end

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
		# Create the default environment options for the company.
		# Admins can always change them once the company has been created.
		
		@company = Company.create(params)

		BuildingAmenity.create([
			{name: "Gym/atheletic facility", company: @company},
			{name: "Sauna", company: @company},
			{name: "Doorman", company: @company},
			{name: "Laundry in bldg", company: @company},
			{name: "Bike room", company: @company},
			{name: "Brownstone", company: @company},
			{name: "Roof deck", company: @company},
			{name: "Garage parking", company: @company},
			{name: "Elevator", company: @company}
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

		RequiredSecurity.create([
			{name: "First month", company: @company},
			{name: "First and last month", company: @company},
			{name: "First, last and 2 months", company: @company},
			{name: "First, last and 3 months", company: @company},
			{name: "Broker's fee", company: @company},
			{name: "Broker's fee and first month", company: @company},
		])

		PetPolicy.create([
			{name: "Cats ok", company: @company},
			{name: "Dogs ok", company: @company},
			{name: "Pets ok", company: @company},
			{name: "Small pets ok (<30 lbs)", company: @company},
			{name: "No pets", company: @company},
		])

		ResidentialAmenity.create([
			{name: "Washer/dryer in unit", company: @company},
			{name: "Washer/dryer hookups", company: @company},
			{name: "Central A/C", company: @company},
			{name: "Central heat", company: @company},
			{name: "Airconditioning", company: @company},
			{name: "Balcony/Terrace", company: @company},
			{name: "Private yard", company: @company},
			{name: "Shared yard", company: @company},
			{name: "Bay windows", company: @company},
			{name: "Dishwasher", company: @company},
			{name: "Microwave", company: @company},
			{name: "Doorman", company: @company},
			{name: "Duplex", company: @company},
			{name: "Triplex", company: @company},
			{name: "Railroad", company: @company},
			{name: "Renovated", company: @company},
			{name: "Roof access", company: @company},
			{name: "Skylight", company: @company},
			{name: "Walk-in closet", company: @company},
			{name: "Waterfront", company: @company},
		])

		CommercialPropertyType.create([
			{property_type: "Retail", property_sub_type: "Retail - Retail Pad", company: @company},
			{property_type: "Retail", property_sub_type: "Retail - Free Standing Bldg", company: @company},
			{property_type: "Retail", property_sub_type: "Retail - Street Retail", company: @company},
			{property_type: "Retail", property_sub_type: "Retail - Vehicle Related", company: @company},
			{property_type: "Retail", property_sub_type: "Retail - Retail (Other)", company: @company},
			{property_type: "Office", property_sub_type: "Office - Office (Other)", company: @company},
			{property_type: "Industrial", property_sub_type: "Industrial - Industrial (Other)", company: @company},
			{property_type: "Land", property_sub_type: "Land - Land (Other)", company: @company},
			{property_type: "Special Purpose", property_sub_type: "Special Purpose - Special Purpose (Other)", company: @company},
		])

		@company
	end
end
