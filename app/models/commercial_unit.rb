class CommercialUnit < ActiveRecord::Base
	acts_as :unit
  belongs_to :commercial_property_type
  scope :unarchived, ->{where(archived: false)}
  before_validation :generate_unique_id
  after_update :clear_cache
  after_destroy :clear_cache
  
  attr_accessor :property_type, :inaccuracy_description

  enum construction_status: [ :existing, :under_construction ]
  validates :construction_status, presence: true, inclusion: { in: %w(existing under_construction) }
  
  enum lease_type: [ :na, :full_service, :nnn, :modified_gross, :modified_net, :industrial_gross, :other ]
  validates :lease_type, presence: true, inclusion: { in: %w(na full_service nnn modified_gross modified_net industrial_gross other) }

	validates :sq_footage, presence: true, :numericality => { :less_than_or_equal_to => 99999999 }
	validates :floor, presence: true, :numericality => { :less_than_or_equal_to => 999 }
	validates :building_size, presence: true, :numericality => { :less_than_or_equal_to => 99999999 }

  def memcache_iterator
    # fetch the user's memcache key
    # If there isn't one yet, assign it a random integer between 0 and 10
    Rails.cache.fetch("cunit-#{id}-memcache-iterator") { rand(10) }
  end

  def cache_key
    "cunit-#{id}-#{self.memcache_iterator}"
  end

  def cached_building
    Rails.cache.fetch("#{cache_key}-building") {
      building
    }
  end
  
  def cached_neighborhood
    Rails.cache.fetch("#{cache_key}-neighborhood") {
      cached_building.neighborhood
    }
  end

  def cached_primary_img
    Rails.cache.fetch("#{cache_key}-primary_img") {
      images[0] ? images[0] : nil
    }
  end

  def cached_street_address
    Rails.cache.fetch("#{cache_key}-street_address") {
      cached_building.street_address
    }
    #building.street_address
  end

  def archive
    self.archived = true
    self.save
  end

  def self.find_unarchived(id)
    find_by!(id: id, archived: false)
  end

	# used as a sorting condition
  def landlord_by_code
    building.landlord.code
  end

  def summary
  	summary = status.capitalize() + ' - ' + commercial_property_type.property_type
  	if commercial_property_type.property_sub_type
  		summary += ' (' + commercial_property_type.property_sub_type + ')'
  	end

  	summary
  end

  def price_per_sq_ft
    rent.to_f / sq_footage
  end

  def self.search(params, building_id=nil)
    # actable_type to restrict to commercial only
    if !params && !building_id
      return CommercialUnit.unarchived
    elsif !params && building_id
      return CommercialUnit.unarchived.where(building_id: building_id)
    end

    @running_list = Unit.includes(:building).unarchived
    
    # clear out any invalid search params
    #params.delete_if{|k,v| !(v || v > 0 || !v.empty?) }
    params.delete_if{|k,v| (!v || v == 0 || v.empty?) }

    # search by address (building)
    if params[:address]
      # cap query string length for security reasons
      address = params[:address][0, 256]
      @terms = address.split(" ")
      @terms.each do |term|
       @running_list = @running_list.joins(:building)
       .where('formatted_street_address ILIKE ?', "%#{term}%")
      end
    end

    # search by status
    if params[:status]
      included = %w[active off].include?(params[:status])
      if included
       @running_list = @running_list.where("status = ?", Unit.statuses[params[:status]])
      end
    end

    # search by rent
    if params[:rent_min] && params[:rent_max]
      @running_list = @running_list.where("rent >= ? AND rent <= ?", params[:rent_min], params[:rent_max])
    elsif params[:rent_min] && !params[:rent_max]
      @running_list = @running_list.where("rent >= ?", params[:rent_min])
    elsif !params[:rent_min] && params[:rent_max]
      @running_list = @running_list.where("rent <= ?", params[:rent_max])
    end

    # search neighborhoods
    if params[:neighborhood_ids]
      neighborhood_ids = params[:neighborhood_ids][0, 256]
      neighborhoods = neighborhood_ids.split(",")
      @running_list = @running_list.joins(building: :neighborhood)
       .where('neighborhood_id IN (?)', neighborhoods)
    end

    # search landlord code
    if params[:landlord]
      @running_list = @running_list.joins(building: :landlord)
      .where("code ILIKE ?", "%#{params[:landlord]}%")
    end

    # the following fields are on CommercialUnit not Unit, so cast the 
    # objects first
    @running_list = Unit.get_commercial(@running_list)

    # search features
    # if params[:property_type]
    #   @running_list = @running_list.joins(:commercial_property_type)
    #   .where("commercial_property_type_id ILIKE ?", "%#{params[:landlord]}%")
      
    @running_list.uniq
  end

  def duplicate(new_unit_num, include_photos)
    if new_unit_num
      commercial_unit_dup = self.dup
      #commercial_unit_dup.listing_id = Unit.generate_unique_id
      commercial_unit_dup.building_unit = new_unit_num
      # TODO: photos
      commercial_unit_dup.save
      commercial_unit_dup
    else
      raise "no unit number specified"
    end
  end

  def send_inaccuracy_report(reporter)
    if reporter
      UnitMailer.commercial_inaccuracy_reported(self, reporter).deliver_now
    else 
      raise "No reporter specified"
    end
  end

  # collect the data we will need to access from our giant map view
  def self.set_location_data(cunits)
    map_infos = {}
    for i in 0..cunits.length-1
      bldg = cunits[i].cached_building
      street_address = bldg.street_address
      bldg_info = {
        building_id: bldg.id,
        lat: bldg.lat, 
        lng: bldg.lng }
      unit_info = {
        id: cunits[i].id,
        building_unit: cunits[i].building_unit,
        rent: cunits[i].rent,
        property_type: cunits[i].commercial_property_type.name,
        sq_footage: cunits[i].sq_footage
       }

      if map_infos.has_key?(street_address)
        map_infos[street_address]['units'] << unit_info
      else
        bldg_info['units'] = [unit_info]
        map_infos[street_address] = bldg_info
      end

    end

    map_infos.to_json
  end

  def clear_cache
    increment_memcache_iterator
    building.increment_memcache_iterator
  end

  private
    def generate_unique_id
      self.listing_id = SecureRandom.random_number(9999999)
      while CommercialUnit.find_by(listing_id: listing_id) do
        self.listing_id = rand(9999999)
      end
      self.listing_id
    end

    # we can't expire old keys with a regex or delete_matched on dalli
    # instead use the strategy suggested here:
    # https://quickleft.com/blog/faking-regex-based-cache-keys-in-rails/
    def increment_memcache_iterator
      Rails.cache.write("cunit-#{id}-memcache-iterator", self.memcache_iterator + 1)
    end
end