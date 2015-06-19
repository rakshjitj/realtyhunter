class Landlord < ActiveRecord::Base
	scope :unarchived, ->{where(archived: false)}

	has_many :buildings, dependent: :destroy
	belongs_to :company
	validates :company, presence: true

	belongs_to :required_security
	validates :required_security, presence: true

	validates :code, presence: true, length: {maximum: 100}, 
		uniqueness: { case_sensitive: false }

	validates :name, presence: true, length: {maximum: 100}, 
		uniqueness: { case_sensitive: false }

	validates :listing_agent_percentage, presence: true, length: {maximum: 3}, numericality: { only_integer: true }

	VALID_TELEPHONE_REGEX = /(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?/
	validates :mobile, presence: true, length: {maximum: 25}, 
		format: { with: VALID_TELEPHONE_REGEX }
	validates :office_phone, allow_blank: true, length: {maximum: 25}, 
		format: { with: VALID_TELEPHONE_REGEX }
	validates :fax, length: {maximum: 25}, 
		format: { with: VALID_TELEPHONE_REGEX }, allow_blank: true

	before_save :downcase_email
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: {maximum: 100}, 
		format: { with: VALID_EMAIL_REGEX }, 
    uniqueness: { case_sensitive: false }

  def archive
    self.archived = true
    self.save
  end

  def self.find_unarchived(id)
    find_by!(id: id, archived: false)
  end

	def active_units_count
		buildings.reduce(0){|sum, bldg| sum + bldg.active_units.count }
	end

	def total_units_count
		buildings.reduce(0){|sum, bldg| sum + bldg.units.count }
	end

	def last_unit_updated
		if !self.buildings.empty?
			buildings = self.buildings.joins(:units).order('updated_at DESC')
			if !buildings.empty?
				buildings.first.updated_at.strftime("%Y-%b-%d")
			else 
				'-No units-'
			end
		else
			'-No buildings-'
		end
	end

	def self.search(params)
		@running_list = Landlord.unarchived
		if !params
	    return @running_list 
  	end

  	if params[:query_str]
	    terms = params[:query_str].split(" ")
	    terms.each do |term|
	      @running_list = @running_list.where('name ILIKE ? or code ILIKE ?', "%#{term}%", "%#{term}%").all
	    end
	  end

    if params[:active_only] == "true"
    	# 'active' is always the first status, so search with 0
    	@running_list = @running_list.joins(buildings: :units).where("status = 0")
    end

    @running_list.uniq
	end

	def residential_units
    bldg_ids = self.building_ids
    units = Unit.where(building_id: bldg_ids)
    @residential_units = Unit.get_residential(units)
  end

  def commercial_units
  	bldg_ids = self.building_ids
    units = Unit.where(building_id: bldg_ids)
    @commercial_units = Unit.get_commercial(units)
  end

	private
    # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end
	
end
