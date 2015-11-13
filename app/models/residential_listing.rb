class ResidentialListing < ActiveRecord::Base
  scope :unarchived, ->{where(archived: false)}
  has_and_belongs_to_many :residential_amenities
  has_many :roommates
  belongs_to :unit, touch: true
  before_save :process_custom_amenities

  attr_accessor :include_photos, :inaccuracy_description,
    :pet_policy_shorthand, :available_starting, :available_before, :custom_amenities

	validates :lease_start, presence: true, length: {maximum: 5}
  validates :lease_end, presence: true, length: {maximum: 5}

	validates :beds, presence: true, :numericality => { :less_than_or_equal_to => 11 }
	validates :baths, presence: true, :numericality => { :less_than_or_equal_to => 11 }

  validates :op_fee_percentage, allow_blank: true, length: {maximum: 3}, numericality: { only_integer: true }
  validates_inclusion_of :op_fee_percentage, :in => 0..100, allow_blank: true

  validates :tp_fee_percentage, allow_blank: true, length: {maximum: 3}, numericality: { only_integer: true }
  validates_inclusion_of :tp_fee_percentage, :in => 0..100, allow_blank: true

  def archive
    self.unit.archived = true
    self.unit.save
  end

  def self.find_unarchived(id)
    ResidentialListing.joins(unit: [building: [:landlord]]) #:neighborhood
      .where(id: id)
      .where('units.archived = false')
      .first
  end

  # used as a sorting condition
  def street_address_and_unit
    output = ""
     # calling from 'show', for example with full objects loaded
    if !self.respond_to? :street_number
      if unit.building.street_number
        output = unit.building.street_number + ' ' + unit.building.route
      end

      if unit.building_unit && !unit.building_unit.empty?
        output = output + ' #' + unit.building_unit
      end
    else # otherwise, we used a select statement to cherry pick fields
      if street_number
        output = street_number + ' ' + route
      end

      if !building_unit.blank?
        output = output + ' #' + building_unit
      end
    end

    output
  end

  def street_address
    output = ""
     # calling from 'show', for example with full objects loaded
    if !self.respond_to? :street_number
      if unit.building.street_number
        output = unit.building.street_number + ' ' + unit.building.route
      end

    else # otherwise, we used a select statement to cherry pick fields
      if street_number
        output = street_number + ' ' + route
      end
    end

    output
  end

  def amenities_to_s
    amenities = residential_amenities.map{|a| a.name.titleize}
    amenities ? amenities.join(", ") : "None"
  end

  def all_amenities_to_s
    bldg_amenities = unit.building.building_amenities.map{|a| a.name.titleize}
    amenities = residential_amenities.map{|a| a.name.titleize}
    amenities.concat(bldg_amenities)
    amenities ? amenities.join(", ") : "None"
  end

  # for use in search method below
  # returns the first image for each unit
  def self.get_images(list)
    unit_ids = list.map(&:unit_id)
    Image.where(unit_id: unit_ids, priority: 0).index_by(&:unit_id)
  end

  # returns all images for each unit
  # def self.get_all_images(list)
  #   unit_ids = list.map(&:unit_id)
  #   Image.where(unit_id: unit_ids).to_a.group_by(&:unit_id)
  # end

  def self.get_amenities(list)
    ids = list.map(&:id)
    ResidentialAmenity.where(residential_listing_id: ids).select('name').to_a.group_by(&:residential_listing_id)
  end

  def self.listings_by_neighborhood(user, listing_ids)
    running_list = ResidentialListing.joins(unit: {building: [:company, :landlord, :neighborhood]})
      .where('companies.id = ?', user.company_id)
      .where('units.listing_id IN (?)', listing_ids)
      .select('buildings.formatted_street_address',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'buildings.lat', 'buildings.lng', 'units.id AS unit_id',
        'units.building_unit', 'units.status','units.rent', 'residential_listings.beds',
        'beds || \'/\' || baths as bed_and_baths',
        'buildings.street_number || \' \' || buildings.route as street_address_and_unit',
        'residential_listings.id', 'residential_listings.baths','units.access_info',
        'residential_listings.has_fee', 'residential_listings.updated_at',
        'neighborhoods.name AS neighborhood_name', 'neighborhoods.id AS neighborhood_id',
        'landlords.code AS landlord_code','landlords.id AS landlord_id',
        'units.available_by')
      .to_a.group_by(&:neighborhood_name)
      #'residential_listings.for_roomsharing',
    running_list
  end

  def self.listings_by_id(user, listing_ids)
    running_list = ResidentialListing.joins(unit: {building: [:company, :landlord, :neighborhood]})
      .where('companies.id = ?', user.company_id)
      .where('units.listing_id IN (?)', listing_ids)
      .select('buildings.formatted_street_address',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'buildings.lat', 'buildings.lng', 'units.id AS unit_id',
        'units.building_unit', 'units.status','units.rent', 'residential_listings.beds',
        'beds || \'/\' || baths as bed_and_baths',
        'buildings.street_number || \' \' || buildings.route as street_address_and_unit',
        'residential_listings.id', 'residential_listings.baths','units.access_info',
        'residential_listings.has_fee', 'residential_listings.updated_at',
        'neighborhoods.name AS neighborhood_name', 'neighborhoods.id AS neighborhood_id',
        'landlords.code AS landlord_code','landlords.id AS landlord_id',
        'units.available_by', 'units.public_url')
      #'residential_listings.for_roomsharing',
    running_list
  end

  def self.export_all(user)
    ResidentialListing.joins(unit: [building: [:company, :landlord, :neighborhood]])
      .where('companies.id = ?', user.company_id)
      .select('buildings.formatted_street_address',
        'units.listing_id', 'units.building_unit', 'units.status','units.rent', 'units.archived',
        'units.available_by', 'units.public_url', 'units.access_info', 'units.exclusive',
        'units.primary_agent_id', 'units.primary_agent2_id',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'buildings.lat', 'buildings.lng',
        'residential_listings.beds', 'residential_listings.baths', 'residential_listings.notes',
        'residential_listings.description', 'residential_listings.lease_start',
        'residential_listings.lease_end', 'residential_listings.has_fee',
        'residential_listings.op_fee_percentage','residential_listings.tp_fee_percentage',
        'residential_listings.tenant_occupied', 'residential_listings.created_at',
        'residential_listings.updated_at',
        'neighborhoods.name AS neighborhood_name', 'neighborhoods.id AS neighborhood_id',
        'landlords.code AS landlord_code','landlords.id AS landlord_id')
#'residential_listings.for_roomsharing',
  end

  # takes in a hash of search options
  # can be formatted_street_address, landlord
  # status, unit, bed_min, bed_max, bath_min, bath_max, rent_min, rent_max,
  # neighborhoods, has_outdoor_space, features, pet_policy, ...
  def self.search(params, user, building_id=nil)
    # TODO: add amenities back in
    # 'building_amenities.name AS bldg_amenity_name',
    running_list = ResidentialListing.joins(unit: {building: [:company, :landlord, :neighborhood]})
      .where('units.archived = false')
      .where('companies.id = ?', user.company_id)
      .select('buildings.formatted_street_address',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'buildings.lat', 'buildings.lng', 'units.id AS unit_id',
        'units.building_unit', 'units.status','units.rent', 'residential_listings.beds',
        'beds || \'/\' || baths as bed_and_baths',
        'buildings.street_number || \' \' || buildings.route as street_address_and_unit',
        'residential_listings.id', 'residential_listings.baths','units.access_info',
        'residential_listings.has_fee', 'residential_listings.updated_at',
        'neighborhoods.name AS neighborhood_name', 'neighborhoods.id AS neighborhood_id',
        'landlords.code AS landlord_code','landlords.id AS landlord_id',
        'units.listing_id', 'units.available_by', 'units.public_url')
      # unit.building.street_number + ' ' + unit.building.route
      #'residential_listings.for_roomsharing',
    if !params && !building_id
      return running_list
    elsif !params && building_id
      # TODO
      #running_list = running_list.where(building_id: building_id)
      #return running_list
    end

    # only admins are allowed to view off-market units
    if !user.is_management?
     running_list = running_list.where.not('status = ?', Unit.statuses['off'])
    end

    # all search params come in as strings from the url
    # clear out any invalid search params
    params.delete_if{ |k,v| (!v || v == 0 || v.empty?) }

    # search by address (building)
    if params[:address]
      # cap query string length for security reasons
      address = params[:address][0, 500]
      running_list =
       running_list.where('buildings.formatted_street_address ILIKE ?', "%#{address}%")
    end

    # search by unit
    if params[:unit]
      # cap query string length for security reasons
      address = params[:unit][0, 50]
      running_list = running_list.where("building_unit ILIKE ?", "%#{params[:unit]}%")
    end

    # search by status
    if params[:status]
      status = params[:status].downcase
      included = ['active + pending', 'active', 'pending', 'off'].include?(status)
      if included
        if status == 'active + pending'
          running_list = running_list.where("status = ? or status = ?",
            Unit.statuses["active"], Unit.statuses["pending"])
        else
          running_list = running_list.where("status = ?", Unit.statuses[status])
        end
      end
    end

    # search by rent
    if params[:rent_min] && params[:rent_max]
      running_list = running_list.where("rent >= ? AND rent <= ?", params[:rent_min], params[:rent_max])
    elsif params[:rent_min] && !params[:rent_max]
      running_list = running_list.where("rent >= ?", params[:rent_min])
    elsif !params[:rent_min] && params[:rent_max]
      running_list = running_list.where("rent <= ?", params[:rent_max])
    end

    # search neighborhoods
    if params[:neighborhood_ids]
      neighborhood_ids = params[:neighborhood_ids][0, 256]
      neighborhoods = neighborhood_ids.split(",").select{|i| !i.strip.empty?}
      #puts "**** #{neighborhoods.inspect}"
      if neighborhoods.length > 0 # ignore empty selection
        running_list = running_list
         .where('neighborhood_id IN (?)', neighborhoods)
      end
    end

    if params[:building_feature_ids]
      features = params[:building_feature_ids][0, 256]
      features = features.split(",").select{|i| !i.empty?}
        bldg_ids = Building.joins(:building_amenities).where('building_amenity_id IN (?)', features).map(&:id)
        running_list = running_list.where("building_id IN (?)", bldg_ids)
    end

    # search landlord code
    if params[:landlord]
      running_list = running_list
      .where("code ILIKE ?", "%#{params[:landlord]}%")
    end

    # search pet policy
    if params[:pet_policy_shorthand]
      pp = params[:pet_policy_shorthand].downcase
      policies = nil
      if pp == "none"
        policies = PetPolicy.where(name: "no pets", company: user.company)
      elsif pp == "cats only"
        policies = PetPolicy.policies_that_allow_cats(user.company, true)
      elsif pp == "dogs only"
        policies = PetPolicy.policies_that_allow_dogs(user.company, true)
      end

      if policies
        running_list = running_list#.joins(building: :pet_policy)
          .where('pet_policy_id IN (?)', policies.ids)
      end
    end

    if !params[:available_starting].blank?
      running_list = running_list.where('available_by > ?', params[:available_starting]);
    end
    if !params[:available_before].blank?
      running_list = running_list.where('available_by < ?', params[:available_before]);
    end

    # search beds
    params.delete('bed_min') if params[:bed_min] == 'Any'
    params.delete('bed_max') if params[:bed_max] == 'Any'
    if params[:bed_min] && params[:bed_max]
      if params[:bed_min].downcase == 'studio/loft'
        params[:bed_min] = 0
      end
      if params[:bed_max].downcase == 'studio/loft'
        params[:bed_max] = 0
      end

      running_list = running_list.where("beds >= ? AND beds <= ?", params[:bed_min], params[:bed_max])
    elsif params[:bed_min] && !params[:bed_max]
      running_list = running_list.where("beds >= ?", params[:bed_min])
    elsif !params[:bed_min] && params[:bed_max]
      running_list = running_list.where("beds <= ?", params[:bed_max])
    end

    # search baths
    params.delete('bath_min') if params[:bath_min] == 'Any'
    params.delete('bath_max') if params[:bath_max] == 'Any'
    if params[:bath_min] && params[:bath_max]
      running_list = running_list.where("baths >= ? AND baths <= ?", params[:bath_min], params[:bath_max])
    elsif params[:bath_min] && !params[:bath_max]
      running_list = running_list.where("baths >= ?", params[:bath_min])
    elsif !params[:bath_min] && params[:bath_max]
      running_list = running_list.where("baths <= ?", params[:bath_max])
    end

    # search by brokers fee
    if params[:has_fee]
      has_fee = params[:has_fee].downcase
      included = %w[yes no].include?(has_fee)
      if included
        running_list = running_list.where(has_fee: has_fee == "yes")
      end
    end

    # search features
    if params[:unit_feature_ids]
      # sanitize input
      features = params[:unit_feature_ids][0, 256]
      features = features.split(",").select{|i| !i.empty?}
      running_list = running_list.joins(:residential_amenities)
        .where('residential_amenity_id IN (?)', features)
    end

    # roomsharing only
    if params[:roomsharing_filter] == 'true'
      # roomsharing apartments are defined as 'apartments with 3+ bedrooms'
      #running_list = running_list.where(for_roomsharing: true)
      running_list = running_list.where('beds >= 3');
    end

    # unassigned listings only
    if params[:unassigned_filter] == 'true'
      running_list = running_list.where(
        'units.primary_agent_id IS NULL AND units.primary_agent2_id IS NULL')
    end

    running_list
  end

  # TODO: run this in the background. See Image class for stub
  def deep_copy_imgs(dst_id)
    #puts "YEAAAAAA MAN #{src_id} #{dst_id}"
    #@src = ResidentialListing.find(src_id)
    @dst = ResidentialListing.find(dst_id)

    # deep copy photos
    self.unit.images.each {|i|
      img_copy = Image.new
      img_copy.file = i.file
      img_copy.unit_id = @dst.unit.id
      img_copy.save
      @dst.unit.images << img_copy
    }
    @dst.save!
  end

  def duplicate(new_unit_num, include_photos=false)
    if new_unit_num && new_unit_num != self.id
      # copy objects
      unit_dup = self.unit.dup
      unit_dup.building_unit = new_unit_num
      unit_dup.listing_id = nil
      if unit_dup.save!

        residential_unit_dup = self.dup
        residential_unit_dup.update(unit_id: unit_dup.id)

        self.residential_amenities.each {|a|
          residential_unit_dup.residential_amenities << a
        }
      else
        raise "Error saving unit"
      end

      #Image.async_copy_residential_unit_images(self.id, residential_unit_dup.id)
      if include_photos
        self.deep_copy_imgs(residential_unit_dup.id)
      end

      #building.increment_memcache_iterator
      #puts "NEW UNIT NUM #{residential_unit_dup.unit.building_unit}"
      residential_unit_dup
    else
      raise "No unit number, invalid unit number, or unit number already taken specified"
    end
  end

  def self.send_listings(source_agent, listings, images, recipients, sub, msg)
    if source_agent
      UnitMailer.send_residential_listings(source_agent, listings, images, recipients, sub, msg).deliver_now
    else
      "No sender specified"
    end
  end

  def send_inaccuracy_report(reporter)
    if reporter
      UnitMailer.inaccuracy_reported(self, reporter).deliver_now
    else
      raise "No reporter specified"
    end
  end

  def take_off_market(new_lease_end_date)
    if new_lease_end_date
      update({status: :off,
              available_by: new_lease_end_date})
    else
      raise "No lease end date specified"
    end
  end

  def calc_lease_end_date
    end_date = Date.today
    end_date = Date.today >> 12
    # case(lease_duration)
    # when "year"
    #   end_date = Date.today >> 12
    # when "thirteen_months"
    #   end_date = Date.today >> 13
    # when "fourteen_months"
    #   end_date = Date.today >> 14
    # when "fifteen_months"
    #   end_date = Date.today >> 15
    # when "sixteen_months"
    #   end_date = Date.today >> 16
    # when "seventeen_months"
    #   end_date = Date.today >> 17
    # when "eighteen_months"
    #   end_date = Date.today >> 18
    # when "two_years"
    #   end_date = Date.today >> 24
    # else
    #   end_date = Date.today >> 12
    # end

    end_date
  end

  # collect the data we will need to access from our giant map view
  def self.set_location_data(runits)
    map_infos = {}
    for i in 0..runits.length-1
      runit = runits[i]

      if runit.street_number
        street_address = runit.street_number + ' ' + runit.route
      else
        street_address = runit.route
      end

      bldg_info = {
        building_id: runit.building_id,
        lat: runit.lat,
        lng: runit.lng }
      unit_info = {
        id: runits[i].id,
        building_unit: runit.building_unit,
        beds: runit.beds,
        baths: runit.baths,
        rent: runit.rent }

      if map_infos.has_key?(street_address)
        map_infos[street_address]['units'] << unit_info
      else
        bldg_info['units'] = [unit_info]
        map_infos[street_address] = bldg_info
      end

    end

    map_infos.to_json
  end

  def self.for_buildings(bldg_ids, is_active=nil)
    listings = ResidentialListing.joins(unit: {building: [:landlord, :neighborhood]})
      .where('buildings.id in (?)', bldg_ids)
      .where('units.archived = false')
      .select('buildings.formatted_street_address',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'units.building_unit', 'units.status','units.rent', 'units.id AS unit_id',
        'beds || \'/\' || baths as bed_and_baths',
        'residential_listings.beds', 'residential_listings.id',
        'residential_listings.baths','units.access_info',
        'residential_listings.has_fee', 'residential_listings.updated_at',
        'neighborhoods.name AS neighborhood_name',
        'landlords.code AS landlord_code','landlords.id AS landlord_id',
        'units.available_by', 'units.listing_id')
      .order('residential_listings.updated_at desc')
      #'residential_listings.for_roomsharing',

    if is_active
      listings = listings.where.not("status = ?", Unit.statuses["off"])
    end

    unit_ids = listings.map(&:unit_id)
    images = Image.where(unit_id: unit_ids).index_by(&:unit_id)

    return listings, images
  end

  def self.for_units(unit_ids, is_active=nil)
    listings = ResidentialListing.joins(unit: {building: [:landlord, :neighborhood]})
      .where('units.id in (?)', unit_ids)
      .where('units.archived = false')
      .select('buildings.formatted_street_address',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'units.building_unit', 'units.status','units.rent', 'units.id AS unit_id',
        'beds || \'/\' || baths as bed_and_baths',
        'residential_listings.beds', 'residential_listings.id',
        'residential_listings.baths','units.access_info',
        'residential_listings.has_fee', 'residential_listings.updated_at',
        'neighborhoods.name AS neighborhood_name',
        'landlords.code AS landlord_code','landlords.id AS landlord_id',
        'units.available_by', 'units.listing_id')
      #'residential_listings.for_roomsharing',

    if is_active
      listings = listings.where.not("status = ?", Unit.statuses["off"])
    end

    unit_ids = listings.map(&:unit_id)
    images = Image.where(unit_id: unit_ids).index_by(&:unit_id)

    return listings, images
  end

  # Used in our API. Takes in a list of units
  def self.get_amenities(list_of_units)
    unit_ids = list_of_units.map(&:unit_id)
    list = ResidentialListing.joins(:residential_amenities)
      .where(unit_id: unit_ids).select('name', 'unit_id', 'id')
      .to_a.group_by(&:unit_id)
  end

  def can_roomshare
    beds >= 3 && unit.status == Unit.statuses['pending']
  end

  private
    def process_custom_amenities
      if custom_amenities
        amenities = custom_amenities.split(',')
        amenities.each{|a|
          if !a.empty?
            a = a.downcase.strip
            found = ResidentialAmenity.find_by(name: a, company: self.unit.building.company)
            if !found
              self.residential_amenities << ResidentialAmenity.create!(name: a, company: self.unit.building.company)
            end
          end
        }
      end
    end

end