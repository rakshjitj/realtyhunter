class Landlord < ActiveRecord::Base
	has_many :buildings
	
	belongs_to :company
	validates :company, presence: true

	belongs_to :required_security
	validates :required_security, presence: true

	belongs_to :pet_policy
	validates :pet_policy, presence: true

	validates :code, presence: true, length: {maximum: 100}, 
		uniqueness: { case_sensitive: false }

	validates :name, presence: true, length: {maximum: 100}, 
		uniqueness: { case_sensitive: false }

	VALID_TELEPHONE_REGEX = /(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?/
	validates :mobile, presence: true, length: {maximum: 25}, 
		format: { with: VALID_TELEPHONE_REGEX }
	validates :office_phone, presence: true, length: {maximum: 25}, 
		format: { with: VALID_TELEPHONE_REGEX }
	validates :fax, length: {maximum: 25}, 
		format: { with: VALID_TELEPHONE_REGEX }, allow_blank: true

	before_save :downcase_email
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: {maximum: 100}, 
		format: { with: VALID_EMAIL_REGEX }, 
    uniqueness: { case_sensitive: false }

	validates :listing_agent_percentage, presence: true, length: {maximum: 3}

	def active_units_count
		buildings.reduce(0){|sum, bldg| sum + bldg.active_units.count }
	end

	def total_units_count
		buildings.reduce(0){|sum, bldg| sum + bldg.units.count }
	end

	def last_unit_updated_on
		return '-' # TODO
	end	

	def self.search(query_str, agent_query, active_only)
		@running_list = Landlord.all
    if !query_str
      return @running_list
    end
    
    terms = query_str.split(" ")
    terms.each do |term|
      running_list = @running_list.where('name ILIKE ? or code ILIKE ?', "%#{term}%", "%#{term}%")
    end

    # TODO:
    if agent_query
    	#terms = agent_query.split(" ")
	    #terms.each do |term|
	    #  running_list = @running_list.joins(:users).where('users.name ILIKE ?', "%#{term}%")
	    #end
    end

    if active_only == "true"
    	# TODO
    	#@running_list = @running_list
	    #	.joins(:buildings)
	    #	.where(buildings: { units: {status:"active"}})
    end

    @running_list.uniq
	end

	private
    # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end
	
end
