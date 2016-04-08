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

	VALID_TELEPHONE_REGEX = /\A(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?\z/
	validates :mobile, allow_blank: true, length: {maximum: 25},
		format: { with: VALID_TELEPHONE_REGEX }
	validates :office_phone, allow_blank: true, length: {maximum: 25},
		format: { with: VALID_TELEPHONE_REGEX }
	validates :fax, allow_blank: true, length: {maximum: 25},
		format: { with: VALID_TELEPHONE_REGEX }

	before_save :clean_up_important_fields

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, allow_blank: true, length: {maximum: 100},
		format: { with: VALID_EMAIL_REGEX },
    uniqueness: { case_sensitive: false }

  def archive
    self.update({archived: true})
  end

  def self.find_unarchived(id)
    find_by!(id: id, archived: false)
  end

	def update_active_unit_count
		self.update_attribute(:active_unit_count, buildings.reduce(0){|sum, bldg| sum + bldg.active_units.count })
	end

	def update_total_unit_count
		self.update_attribute(:total_unit_count, buildings.reduce(0){|sum, bldg| sum + bldg.units.count })
	end

	def self._search(running_list, params)
		if !params
	    return running_list
  	end

  	if params[:filter]
	    terms = params[:filter].split(" ")
	    terms.each do |term|
	      running_list = running_list.where('landlords.name ILIKE ? or landlords.code ILIKE ?',
            "%#{term}%", "%#{term}%").all
	    end
	  end

    status = params[:status]
    if !status.nil?
      status_lowercase = status.downcase
      if status_lowercase != 'any'
        if status_lowercase == 'active/pending'
          running_list = running_list.joins(buildings: :units)
              .where("units.status IN (?) ",
                [Unit.statuses['active'], Unit.statuses['pending']])#.uniq
        else
          running_list = running_list.joins(buildings: :units)
              .where("units.status = ? ", Unit.statuses[status_lowercase])#.uniq
        end
      end
    end

    running_list.uniq
	end

	def self.search_csv(params)
		running_list = Landlord.unarchived.includes(:buildings)
		self._search(running_list, params)
	end

	def self.search(params)
		running_list = Landlord.unarchived
    running_list = self._search(running_list, params)
		running_list = running_list.select('landlords.id', 'landlords.code', 'landlords.name',
				'landlords.updated_at', 'landlords.mobile',
				'landlords.active_unit_count', 'landlords.total_unit_count',
				'landlords.last_unit_updated_at')

	end

	def residential_units(status=nil)
    bldg_ids = self.building_ids
    ResidentialListing.for_buildings(bldg_ids, status)
  end

  def commercial_units(status=nil)
  	bldg_ids = self.building_ids
    CommercialListing.for_buildings(bldg_ids, status)
  end

	private
    def clean_up_important_fields
    	if email
      	self.email = email.gsub(/\A\p{Space}*|\p{Space}*\z/, '').downcase
     	end

			self.name = name.gsub(/\A\p{Space}*|\p{Space}*\z/, '')
			self.code = code.gsub(/\A\p{Space}*|\p{Space}*\z/, '')
    end

end
