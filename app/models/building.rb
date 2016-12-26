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
  has_many :documents, dependent: :destroy

	has_and_belongs_to_many :building_amenities
	has_and_belongs_to_many :utilities

	attr_accessor :building, :inaccuracy_description,
    :custom_rental_term, :custom_amenities, :custom_utilities, :custom_neighborhood_id

  # can't be unique. we might have archived copies with the same address
	validates :formatted_street_address, presence: true, length: {maximum: 200}
		#uniqueness: { case_sensitive: false }

	validates :street_number, allow_blank: true, length: {maximum: 20}
	validates :route, presence: true, length: {maximum: 100}
	# borough
	#:sublocality can be blank
	# city
	validates :administrative_area_level_2_short, allow_blank: true, length: {maximum: 100}
	# state
	validates :administrative_area_level_1_short, presence: true, length: {maximum: 100}
	validates :postal_code, allow_blank: true, length: {maximum: 15}
	validates :country_short, presence: true, length: {maximum: 100}
	validates :lat, presence: true, length: {maximum: 100}
	validates :lng, presence: true, length: {maximum: 100}
	validates :place_id, presence: true, length: {maximum: 100}

  validates :llc_name, allow_blank: true, length: {maximum: 200}

	validates :company, presence: true
  # don't validate landlord presence here - if this building has sales listings instead of rentals,
  # for example, then there will be a seller instead of a landlord. only rentals have landlord info.

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
    units.unarchived.available_on_market.order('updated_at DESC')
	end

	def update_total_unit_count
    self.update_attribute(:total_unit_count, units.unarchived.count)
	end

	def update_active_unit_count
    active_count = units.unarchived.where('status = ?', Unit.statuses['active']).count
    self.update_attribute(:active_unit_count, active_count)
	end

  # get first image as thumbnail
  def self.get_bldg_images_from_units(list)
    imgs = Image.where(building_id: list.pluck(:building_id), priority: 0)
    Hash[imgs.map {|img| [img.building_id, img.file.url(:thumb)]}]
  end

  # get first image as thumbnail
  def self.get_images(list)
    imgs = Image.where(building_id: list.ids, priority: 0)
    Hash[imgs.map {|img| [img.building_id, img.file.url(:thumb)]}]
  end

  # returns all images for each building
  def self.get_all_bldg_images(list)
    building_ids = list.map(&:building_id)
    Image.where(building_id: building_ids).to_a.group_by(&:building_id)
  end

  def self._filter_query(running_list, query_str, status)
    if query_str
      @terms = query_str.split(" ")
      @terms.each do |term|
        running_list = running_list.where('buildings.formatted_street_address ILIKE ? OR buildings.sublocality ILIKE ?', "%#{term}%", "%#{term}%")
      end
    end

    if !status.nil?
      status_lowercase = status.downcase
      if status_lowercase != 'any'
        if status_lowercase == 'active/pending'
          running_list = running_list.joins(:units)
              .where("units.status IN (?) ",
                [Unit.statuses['active'], Unit.statuses['pending']])
        else
          running_list = running_list.joins(:units)
              .where("units.status = ? ", Unit.statuses[status_lowercase])
        end
      end
    end

    running_list#.uniq
  end

	def self.search(query_str, status)
    running_list = Building
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .where('buildings.archived = false')
      .select(
        'buildings.formatted_street_address', 'buildings.notes',
        'buildings.id', 'buildings.street_number', 'buildings.route',
        'buildings.sublocality', 'buildings.neighborhood_id', 'neighborhoods.name as neighborhood_name',
        'buildings.administrative_area_level_2_short',
        'buildings.administrative_area_level_1_short', 'buildings.postal_code',
        'buildings.updated_at', 'buildings.created_at',
        'buildings.last_unit_updated_at',
        'buildings.total_unit_count',
        'buildings.active_unit_count')

    running_list = Building._filter_query(running_list, query_str, status)
    running_list
	end

  # adds in landlord
  def self.export_all(query_str, status)
    running_list = Building.joins(:landlord)
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .where('buildings.archived = false')
      .select(
        'landlords.code AS landlord_code','landlords.id AS landlord_id',
        'buildings.formatted_street_address', 'buildings.notes',
        'buildings.id', 'buildings.street_number', 'buildings.route',
        'buildings.sublocality', 'buildings.neighborhood_id', 'neighborhoods.name as neighborhood_name',
        'buildings.administrative_area_level_2_short',
        'buildings.administrative_area_level_1_short', 'buildings.postal_code', 'buildings.llc_name',
        'buildings.updated_at', 'buildings.created_at',
        'buildings.last_unit_updated_at',
        'buildings.total_unit_count',
        'buildings.active_unit_count')

    running_list = Building._filter_query(running_list, query_str, status)
    running_list
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
		@neigh = Neighborhood.where(name: neighborhood).first
    if !@neigh
      @neigh = Neighborhood.create(
        name: neighborhood,
        borough: borough,
        city: city,
        state: state)
    end
    self.neighborhood = @neigh
  end

  def send_inaccuracy_report(reporter, message)
    BuildingMailer.inaccuracy_reported(self.id, reporter.id, message).deliver
  end

  def residential_units(status=nil)
    ResidentialListing.for_buildings([id], status)
  end

  def commercial_units(status=nil)
    CommercialListing.for_buildings([id], status)
  end

  # used in API, syndication
  def self.get_pet_policies(list)
    bldg_ids = list.pluck(:building_id)
    Building.joins(:pet_policy).where(id: bldg_ids)
      .select('buildings.id', 'pet_policies.name as pet_policy_name')
      .to_a.group_by(&:id)
  end

  def self.get_rental_terms(list_of_units)
    bldg_ids = list_of_units.pluck(:building_id)
    Building.joins(:rental_term).where(id: bldg_ids)
      .select('buildings.id', 'rental_terms.name as rental_term_name')
      .to_a.group_by(&:id)
  end

  # Used in our API
  def self.get_amenities(list_of_units)
    building_ids = list_of_units.map(&:building_id)
    Building.joins(:building_amenities)
        .where(id: building_ids).select('name', 'id')
        .to_a.group_by(&:id)
  end

  # used by building csv
  def self.get_amenities_from_buildings(list_of_bldgs)
    building_ids = list_of_bldgs.pluck(:id)
    Building.joins(:building_amenities)
        .where(id: building_ids).select('name', 'id')
        .to_a.group_by(&:id)
  end

  # Used by syndication
  def self.get_utilities(list_of_units)
    bldg_ids = list_of_units.pluck(:building_id)
    Building.joins(:utilities).where(id: bldg_ids)
        .select('buildings.id', 'utilities.name as utility_name')
        .to_a.group_by(&:id)
  end

  # used by building csv
  def self.get_utilities_from_buildings(list_of_bldgs)
    bldg_ids = list_of_bldgs.pluck(:id)
    Building.joins(:utilities).where(id: bldg_ids)
        .select('buildings.id', 'utilities.name as utility_name')
        .to_a.group_by(&:id)
  end

  private

  	def process_rental_term
  		if custom_rental_term && !custom_rental_term.empty?
  			req = RentalTerm.where(name: custom_rental_term, company: company).first
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
            found = BuildingAmenity.where(name: a, company: company).first
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
            found = Utility.where(name: t, company: company).first
            if !found
              self.utilities << Utility.create!(name: t, company: company)
            end
          end
        }
      end
    end

end
