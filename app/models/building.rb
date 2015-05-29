class Building < ActiveRecord::Base
	belongs_to :company
	belongs_to :landlord
	belongs_to :listing_agent, :foreign_key => 'user_id', :class_name => 'User'
	has_many :units #, -> { order('posted_at DESC') }
	belongs_to :neighborhood
	has_and_belongs_to_many :building_amenities

	# TODO: remove this line
	# this is some BS we need to make cancancan happy, because it 
	# does not like our strong parameters
	attr_accessor :building

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
	validates :listing_agent, presence: true

	def street_address
		self.street_number + ' ' + self.route
	end

	def active_units
		self.units.where(status: "active")
	end

	def total_units_count
		self.units.count
	end

	def active_units_count
		self.units.where(status: "active").count
	end

	def self.search(query_str, active_only)
		@running_list = Building.all
    if !query_str
      return @running_list
    end
    
    @terms = query_str.split(" ")
    @terms.each do |term|
      @running_list = @running_list.where('formatted_street_address ILIKE ? OR sublocality ILIKE ?', "%#{term}%", "%#{term}%")
    end

    if active_only == "true"
    	@running_list = @running_list.joins(:units).where(units: {status:"active"})
    end

    @running_list.uniq
	end

	def amenities
		amenities = self.building_amenities.map{|a| a.name}
		if amenities
			amenities.join(", ")
		else
			"None"
		end
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

end
