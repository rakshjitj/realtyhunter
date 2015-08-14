class Building < ActiveRecord::Base
	scope :unarchived, ->{where(archived: false)}
	
  before_save :process_rental_term
  before_save :process_custom_amenities
  before_save :process_custom_utilities

	belongs_to :company, touch: true
	belongs_to :landlord, touch: true
	belongs_to :neighborhood, touch: true
	belongs_to :pet_policy, touch: true
	belongs_to :rental_term, touch: true
	has_many :units, dependent: :destroy

	has_many :images, dependent: :destroy
  
	has_and_belongs_to_many :building_amenities
	has_and_belongs_to_many :utilities

	attr_accessor :building, :inaccuracy_description, 
    :custom_rental_term, :custom_amenities, :custom_utilities, :custom_neighborhood_id

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
    units.unarchived.on_market.order('updated_at DESC')
	end

	def total_units_count
    units.unarchived.count
	end

	def active_units_count
    units.unarchived.on_market.count
	end

	def last_unit_updated
		if self.units.length > 0
			self.units.first.updated_at
		else
			'--'
		end
	end

    # for use in search method below
  def self.get_images(list)
    bldg_ids = list.map(&:id)
    Image.where(building_id: bldg_ids, priority: 0).index_by(&:building_id)
  end

	def self.search(query_str, active_only)
    # TODO: remove that extra join
    @running_list = Building.joins(:landlord).includes(:neighborhood)
      .where('buildings.archived = false')
      .select(
        'buildings.formatted_street_address', 'buildings.notes',
        'buildings.id', 'buildings.street_number', 'buildings.route', 
        'buildings.sublocality', 'buildings.neighborhood_id',
        'buildings.administrative_area_level_2_short',
        'buildings.administrative_area_level_1_short', 'buildings.postal_code',
        'buildings.updated_at', 
        'sq.last_unit_updated, sq.total_unit_count',
        'landlords.code AS landlord_code','landlords.id AS landlord_id',
        '(SELECT COUNT(*) FROM units where units.building_id = buildings.id AND units.status != ' + Unit.statuses['off'].to_s + ') AS active_unit_count',
        ).joins('LEFT OUTER JOIN (
          SELECT units.building_id, count(units.id) as total_unit_count, 
          max(units.updated_at) as last_unit_updated
          FROM units 
          GROUP BY units.building_id
        ) sq on sq.building_id = buildings.id')

    return @running_list if !query_str
    
    @terms = query_str.split(" ")
    @terms.each do |term|
      @running_list = @running_list.where('buildings.formatted_street_address ILIKE ? OR buildings.sublocality ILIKE ?', "%#{term}%", "%#{term}%")
    end

    if active_only == "true"
      @running_list = @running_list.joins(:units).where("units.status != ? ", Unit.statuses["off"])
    end

    @running_list
	end

	def amenities_to_s
		amenities = self.building_amenities.map{|a| a.name.titleize}
		amenities = amenities ? amenities.join(', ') : "None"
    amenities
	end

	def utilities_to_s
		terms = self.utilities.map{|a| a.name.titleize}
		terms = terms ? terms.join(', ') : "None"
    terms
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

  def residential_units(active_only=false)
    ResidentialListing.for_buildings([id], active_only)
  end

  def commercial_units(active_only=false)
    CommercialListing.for_buildings([id], active_only)
  end

  private

  	def process_rental_term
  		if custom_rental_term && !custom_rental_term.empty?
  			req = RentalTerm.find_by(name: custom_rental_term, company: company)
  			if !req
  				req = RentalTerm.create!(name: custom_rental_term, company: company)
  			end
  			self.rental_term = req
  		end
  	end

    def process_custom_amenities
      if custom_amenities
        amenities = custom_amenities.split(',')
        amenities.each{|a|
          if !a.empty?
            a = a.downcase.strip
            found = BuildingAmenity.find_by(name: a, company: company)
            if !found
              self.building_amenities << BuildingAmenity.create!(name: a, company: company)
            end
          end
        }
      end
    end

    def process_custom_utilities
      if custom_utilities
        terms = custom_utilities.split(',')
        terms.each{|t|
          t = t.downcase.strip
          if !t.empty?
            found = Utility.find_by(name: t, company: company)
            if !found
              self.utilities << Utility.create!(name: t, company: company)
            end
          end
        }
      end
    end
  
end
