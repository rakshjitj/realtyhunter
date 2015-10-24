class Landlord < ActiveRecord::Base
	scope :unarchived, ->{where(archived: false)}

	has_many :buildings, dependent: :destroy
	belongs_to :company, touch: true
	validates :company_id, presence: true

  belongs_to :listing_agent, :class_name => 'User', touch: true
  validates :listing_agent_percentage, allow_blank: true, length: {maximum: 3}, numericality: { only_integer: true }

	validates :code, presence: true, length: {maximum: 100}, 
		uniqueness: { case_sensitive: false }

	validates :name, presence: true, length: {maximum: 100}

	VALID_TELEPHONE_REGEX = /(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?/
	validates :mobile, allow_blank: true, length: {maximum: 25}, 
		format: { with: VALID_TELEPHONE_REGEX }
	validates :office_phone, allow_blank: true, length: {maximum: 25}, 
		format: { with: VALID_TELEPHONE_REGEX }
	validates :fax, allow_blank: true, length: {maximum: 25}, 
		format: { with: VALID_TELEPHONE_REGEX }

	#before_save :downcase_email
	before_save :clean_up_important_fields

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, allow_blank: true, length: {maximum: 100}, 
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
				buildings.first.updated_at
			else 
				'-No units-'
			end
		else
			'-No buildings-'
		end
	end

	def self._search(params)
		if !params
	    return @running_list 
  	end

  	if params[:filter]
	    terms = params[:filter].split(" ")
	    terms.each do |term|
	      @running_list = @running_list.where('name ILIKE ? or code ILIKE ?', "%#{term}%", "%#{term}%").all
	    end
	  end

    if params[:active_only] == "true"
    	# misnamed. this actually means active + pending
    	@running_list = @running_list.joins(buildings: :units).where.not("status = ?", Unit.statuses["off"]).uniq
    end

    @running_list
	end

	def self.search_csv(params)
		@running_list = Landlord.unarchived.includes(:buildings)
		self._search(params)
	end

	def self.search(params)
		@running_list = Landlord.unarchived.includes(:buildings)
			.select('landlords.id', 'landlords.code', 'landlords.name',
				'landlords.updated_at', 'landlords.mobile')
		self._search(params)
	end

	def residential_units(active_only=false)
    bldg_ids = self.building_ids
    ResidentialListing.for_buildings(bldg_ids, active_only)
  end

  def commercial_units(active_only=false)
  	bldg_ids = self.building_ids
    CommercialListing.for_buildings(bldg_ids, active_only)
  end

	private
    # Converts email to all lower-case.
    # def downcase_email
    # 	if email
    #   	self.email = email.downcase
    #  	end
    # end

    def clean_up_important_fields
    	if email
      	self.email = email.gsub(/\A\p{Space}*|\p{Space}*\z/, '').downcase
     	end
     	
			self.name = name.gsub(/\A\p{Space}*|\p{Space}*\z/, '')
			self.code = code.gsub(/\A\p{Space}*|\p{Space}*\z/, '')
    end
	
end
