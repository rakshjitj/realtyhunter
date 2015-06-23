class Building < ActiveRecord::Base
	belongs_to :company
	belongs_to :landlord
	belongs_to :neighborhood
	has_many :units, dependent: :destroy
	has_many :images, dependent: :destroy
	has_and_belongs_to_many :building_amenities
	has_and_belongs_to_many :rental_terms

	scope :unarchived, ->{where(archived: false)}
	
	# TODO: remove this line
	# this is some BS we need to make cancancan happy, because it 
	# does not like our strong parameters
	attr_accessor :building, :inaccuracy_description

	validates :formatted_street_address, presence: true, length: {maximum: 200}, 
		uniqueness: { case_sensitive: false }
						
	validates :street_number, presence: true, length: {maximum: 20}
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
	validates :neighborhood, presence: true

  def archive
    self.archived = true
    self.save
  end

  def self.find_unarchived(id)
    find_by!(id: id, archived: false)
  end

	def street_address
		street_number + ' ' + route
	end

	def active_units
		self.units.unarchived.active
	end

	def total_units_count
		self.units.count
	end

	def active_units_count
		self.units.unarchived.active.count
	end

	def last_unit_updated
		if self.units
			self.units.order('updated_at DESC').first.updated_at.strftime("%Y-%b-%d")
		else
			'--'
		end
	end

	def self.search(query_str, active_only)
		@running_list = Building.unarchived
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

end
