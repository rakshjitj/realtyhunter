class Building < ActiveRecord::Base
	scope :unarchived, ->{where(archived: false)}
	before_save :process_custom_security
	belongs_to :company, touch: true
	belongs_to :landlord, touch: true
	belongs_to :neighborhood, touch: true
	belongs_to :pet_policy, touch: true
	belongs_to :required_security, touch: true
	has_many :units, dependent: :destroy
	has_many :images, dependent: :destroy
	has_and_belongs_to_many :building_amenities
	has_and_belongs_to_many :rental_terms

	# TODO: remove this line
	# this is some BS we need to make cancancan happy, because it 
	# does not like our strong parameters
	attr_accessor :building, :inaccuracy_description, :custom_required_security

	validates :formatted_street_address, presence: true, length: {maximum: 200}, 
		uniqueness: { case_sensitive: false }
						
	validates :street_number, allow_blank: true, length: {maximum: 20}
	validates :route, presence: true, length: {maximum: 100}
	# borough
	#:sublocality can be blank
	# city
	validates :administrative_area_level_2_short, presence: true, length: {maximum: 100}
	# state
	validates :administrative_area_level_1_short, presence: true, length: {maximum: 100}
	validates :postal_code, presence: true, length: {maximum: 15}
	validates :country_short, presence: true, length: {maximum: 100}
	validates :lat, presence: true, length: {maximum: 100}
	validates :lng, presence: true, length: {maximum: 100}
	validates :place_id, presence: true, length: {maximum: 100}

	validates :company, presence: true
	validates :landlord, presence: true

	# TODO: fix
	# some address lookups don't return a valid neighborhood
	#validates :neighborhood, presence: true

	def cached_neighborhood
    Rails.cache.fetch("building_#{id}_neighborhood") {
      neighborhood
    }
  end

  def cached_landlord
    Rails.cache.fetch("building_#{id}_landlord") {
      landlord
    }
  end

  def cached_primary_img
    Rails.cache.fetch("building_#{id}_primary_img") {
      images[0] ? images[0] : nil
    }
  end

  def cached_units
    Rails.cache.fetch("building_#{id}_units") {
      units.unarchived.order('updated_at DESC')
    }
  end

  def cached_active_units
    Rails.cache.fetch("building_#{id}_active_units") {
      units.unarchived.active.order('updated_at DESC')
    }
  end

  def cached_units_count
    Rails.cache.fetch("building_#{id}_units_count") {
      cached_units.count
    }
  end

  def cached_active_units_count
    Rails.cache.fetch("building_#{id}_active_units_count") {
      cached_active_units.count
    }
  end

  def archive
    self.archived = true
    self.save
  end

  def self.find_unarchived(id)
    find_by!(id: id, archived: false)
  end

	def street_address
		if street_number
			street_number + ' ' + route
		else
			route
		end
	end

	def active_units
		self.cached_active_units
	end

	def total_units_count
		self.cached_units_count
	end

	def active_units_count
		self.cached_active_units_count
	end

	def last_unit_updated
		if self.cached_units.length > 0
			self.cached_units.first.updated_at.strftime("%Y-%b-%d")
		else
			'--'
		end
	end

	def self.search(query_str, active_only)
		@running_list = Building.includes(:images).unarchived
    return @running_list if !query_str
    
    @terms = query_str.split(" ")
    @terms.each do |term|
      @running_list = @running_list.where('formatted_street_address ILIKE ? OR sublocality ILIKE ?', "%#{term}%", "%#{term}%")
    end

    if active_only == "true"
    	@running_list = @running_list.joins(:units).where(units: {status:"active"})
    end

    @running_list.uniq
	end

	def amenities_to_s
		amenities = self.building_amenities.map{|a| a.name}
		amenities ? amenities.join(', ') : "None"
	end

	def rental_terms_to_s
		terms = self.rental_terms.map{|a| a.name}
		terms ? terms.join(', ') : "None"
	end

  def find_or_create_neighborhood(neighborhood, borough, city, state)
		@neigh = Neighborhood.find_by(name: neighborhood)
    if !@neigh
      @neigh = Neighborhood.create(
        name: neighborhood, 
        borough: borough,
        city: city,
        state: state)
    end
    self.neighborhood = @neigh
  end

  def send_inaccuracy_report(reporter)
    BuildingMailer.inaccuracy_reported(self, reporter).deliver_now
  end

  def residential_units
    units = Unit.includes(:building).where(building_id: id)
    units = Unit.get_residential(units)
  end

  def commercial_units
    units = Unit.includes(:building).where(building_id: id)
    Unit.get_commercial(units)
  end

  def active_residential_units
    units = Unit.includes(:building).where(building_id: id, units: {status:"active"})
    units = Unit.get_residential(units)
  end

  def active_commercial_units
    units = Unit.includes(:building).where(building_id: id, units: {status:"active"})
    Unit.get_commercial(units)
  end

  private

  	def process_custom_security
  		if custom_required_security
  			req = RequiredSecurity.where(name: custom_required_security).first
  			if !req
  				req = RequiredSecurity.create!(name: custom_required_security, company: company)
  			end
  			self.required_security = req
  		end
  	end
  
end
