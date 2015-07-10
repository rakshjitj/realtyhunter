class Company < ActiveRecord::Base
	default_scope { order("name ASC") }
	scope :unarchived, ->{where(archived: false)}
	
	has_one :image, dependent: :destroy
	after_save :create_environment
	has_many :offices, :dependent => :destroy
	has_many :users, dependent: :destroy
	accepts_nested_attributes_for :users
	has_many :buildings, dependent: :destroy
	has_many :landlords, dependent: :destroy
	has_many :building_amenities, dependent: :destroy
	has_many :utilities, dependent: :destroy
	has_many :required_securities, dependent: :destroy
	has_many :pet_policies, dependent: :destroy
	has_many :residential_amenities, dependent: :destroy
	has_many :commercial_property_types
	
	#attr_accessor :agent_types, :employee_titles
	#attr_access :building_amenities

	validates :name, presence: true, length: {maximum: 100}, 
		uniqueness: { case_sensitive: false }

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
		users.unarchived.includes(:employee_title, :office, :image, :company, :manager).select{|u| u if u.is_company_admin? }
	end

	def managers
		users.unarchived.includes(:employee_title, :office, :image, :company, :manager).select{|u| u if u.is_manager? }
	end

	def data_enterers
		users.unarchived.includes(:employee_title, :office, :image, :company, :manager).select{|u| u if u.is_data_entry? }
	end

	def update_agent_types
		agent_types.split(/\r?\n/).each {|a|
      sanitized_name = AgentType.sanitize_name(a)
      AgentType.find_or_create_by(name: sanitized_name)
    }
	end

	def update_employee_titles
		employee_titles.split(/\r?\n/).each {|e|
      sanitized_name = EmployeeTitle.sanitize_name(e)
      EmployeeTitle.find_or_create_by(name: sanitized_name)
    }
	end

	def self.search(query_params)
    running_list = Company.unarchived
    if !query_params || !query_params[:name]
      return running_list
    end
    
    query_string = query_params[:name]
    query_string = query_string[0..500] # truncate for security reasons
    terms = query_string.split(" ")
    terms.each do |term|
      running_list = running_list.where('name ILIKE ?', "%#{term}%").all
    end

    running_list.uniq
  end

	# Create the default environment options for the company.
	# Admins can always change them once the company has been created.
	def create_environment		
		BuildingAmenity.create!([
			{name: "Fitness Center", company: self},
			{name: "Sauna", company: self},
			{name: "Doorman", company: self},
			{name: "Laundry in Bldg", company: self},
			{name: "Bike Room", company: self},
			{name: "Brownstone", company: self},
			{name: "Storage", company: self},
			{name: "Roof Deck", company: self},
			{name: "Garage Parking", company: self},
			{name: "Elevator", company: self}
		])

		Utility.create!([
			{name: "Heat included", company: self},
			{name: "Hot water included", company: self},
			{name: "Heat/hot water included", company: self},
			{name: "Gas included", company: self},
			{name: "Electric included", company: self},
			{name: "Cable included", company: self},
			{name: "Internet included", company: self},
			{name: "All utils included", company: self},
			{name: "No utils included", company: self},
			{name: "Water not included", company: self},
			{name: "Trash not included", company: self},
		])

		RequiredSecurity.create!([
			{name: "First & Last month", company: self},
			{name: "First, Last & Security", company: self},
			{name: "First & 2 Securities", company: self},
			{name: "First, Security & Broker's Fee", company: self},
		])

		PetPolicy.create!([
			{name: "Cats only", company: self},
			{name: "Dogs only", company: self},
			{name: "Pets ok", company: self},
			{name: "Small pets ok (<30 lbs)", company: self},
			{name: "Pets upon approval", company: self},
			{name: "Monthly pet fee", company: self},
			{name: "Pet deposit required", company: self},
			{name: "No pets", company: self},
		])

		ResidentialAmenity.create!([
			{name: "Washer/dryer in unit", company: self},
			{name: "Washer/dryer hookups", company: self},
			{name: "Central A/C", company: self},
			{name: "Central heat", company: self},
			{name: "Airconditioning", company: self},
			{name: "Balcony/Terrace", company: self},
			{name: "Hardwood floors", company: self},
			{name: "Private yard", company: self},
			{name: "Shared yard", company: self},
			{name: "Bay windows", company: self},
			{name: "Dishwasher", company: self},
			{name: "Microwave", company: self},
			{name: "Doorman", company: self},
			{name: "Duplex", company: self},
			{name: "Triplex", company: self},
			{name: "Railroad", company: self},
			{name: "Renovated", company: self},
			{name: "Roof access", company: self},
			{name: "Skylight", company: self},
			{name: "Walk-in closet", company: self},
			{name: "Waterfront", company: self},
		])

		CommercialPropertyType.create!([
			{property_type: "Retail", property_sub_type: "Retail - Retail Pad", company: self},
			{property_type: "Retail", property_sub_type: "Retail - Free Standing Bldg", company: self},
			{property_type: "Retail", property_sub_type: "Retail - Street Retail", company: self},
			{property_type: "Retail", property_sub_type: "Retail - Vehicle Related", company: self},
			{property_type: "Retail", property_sub_type: "Retail - Retail (Other)", company: self},
			{property_type: "Office", property_sub_type: "Office - Office (Other)", company: self},
			{property_type: "Industrial", property_sub_type: "Industrial - Industrial (Other)", company: self},
			{property_type: "Land", property_sub_type: "Land - Land (Other)", company: self},
			{property_type: "Special Purpose", property_sub_type: "Special Purpose - Special Purpose (Other)", company: self},
		])
	end
end
