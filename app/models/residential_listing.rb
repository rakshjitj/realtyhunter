class ResidentialListing < ActiveRecord::Base
  queue = :residential_listings
  has_and_belongs_to_many :residential_amenities
  has_many :roommates
  belongs_to :unit, touch: true
  accepts_nested_attributes_for :unit #, allow_destroy: true
  before_save :process_custom_amenities
  after_commit :update_building_counts

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
    update_building_counts
  end

  def self.find_unarchived(id)
    ResidentialListing.joins(unit: [building: [:landlord]])
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
    output = "".freeze
     # calling from 'show', for example with full objects loaded
    if !self.respond_to? :street_number
      #if unit.building.street_number
        output = "#{unit.building.street_number} #{unit.building.route}".freeze
      #end

    else # otherwise, we used a select statement to cherry pick fields
      #if street_number
        output = "#{street_number} #{route}".freeze
      #end
    end

    output
  end

  def amenities_to_s
    amenities = residential_amenities.map{|a| a.name.titleize}
    amenities ? amenities.join(", ") : "None".freeze
  end

  def all_amenities_to_s
    bldg_amenities = unit.building.building_amenities.map{|a| a.name.titleize}
    amenities = residential_amenities.map{|a| a.name.titleize}
    amenities.concat(bldg_amenities)
    amenities ? amenities.join(", ") : "None".freeze
  end

  # returns the first image for each unit - thumbnail styles only
  def self.get_images(list)
    unit_ids = list.pluck(:unit_id)
    imgs = Image.where(unit_id: unit_ids, priority: 0)
    Hash[imgs.map {|img| [img.unit_id, img.file.url(:thumb)]}]
  end

  def self.get_amenities(list)
    ResidentialAmenity.where(residential_listing_id: list.ids)
        .select('name').to_a.group_by(&:residential_listing_id)
  end


  def self.listings_by_neighborhood(user, listing_ids)
    running_list = ResidentialListing.joins(unit: {building: [:company, :landlord]})
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .where('companies.id = ?', user.company_id)
      .where('units.listing_id IN (?)', listing_ids)
      .select('buildings.formatted_street_address',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'buildings.lat', 'buildings.lng', 'units.id AS unit_id',
        'units.building_unit', 'units.status','units.rent', 'residential_listings.beds',
        'buildings.street_number || \' \' || buildings.route as street_address_and_unit',
        'residential_listings.id', 'residential_listings.baths','units.access_info',
        'residential_listings.has_fee', 'residential_listings.updated_at',
        'neighborhoods.name AS neighborhood_name', 'neighborhoods.id AS neighborhood_id',
        'landlords.code',
        'landlords.id AS landlord_id',
        'units.available_by')
      .to_a.group_by(&:neighborhood_name)
    running_list
  end

  def self.listings_by_id(user, listing_ids)
    running_list = ResidentialListing.joins(unit: {building: [:company, :landlord]})
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .where('companies.id = ?', user.company_id)
      .where('units.listing_id IN (?)', listing_ids)
      .select('buildings.formatted_street_address',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'buildings.lat', 'buildings.lng', 'units.id AS unit_id',
        'units.building_unit', 'units.status','units.rent', 'residential_listings.beds',
        'buildings.street_number || \' \' || buildings.route as street_address_and_unit',
        'residential_listings.id', 'residential_listings.baths','units.access_info',
        'residential_listings.has_fee', 'residential_listings.updated_at',
        'neighborhoods.name AS neighborhood_name', 'neighborhoods.id AS neighborhood_id',
        'landlords.code',
        'landlords.id AS landlord_id',
        'units.available_by', 'units.public_url')
    running_list
  end

  def self.export_all(user, params)
    params = params.symbolize_keys
    running_list = ResidentialListing.joins(unit: [building: [:company, :landlord]])
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .joins('left join users on users.id = units.primary_agent_id')
      .where('companies.id = ?', user.company_id)
      .select('buildings.formatted_street_address',
        'units.listing_id', 'units.building_unit', 'units.status','units.rent', 'units.archived',
        'units.available_by', 'units.public_url', 'units.access_info', 'units.exclusive',
        'units.id AS unit_id', 'units.primary_agent_id',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'buildings.lat', 'buildings.lng',
        'residential_listings.id',
        'residential_listings.beds', 'residential_listings.baths', 'residential_listings.notes',
        'residential_listings.description', 'residential_listings.lease_start',
        'residential_listings.lease_end', 'residential_listings.has_fee',
        'residential_listings.op_fee_percentage','residential_listings.tp_fee_percentage',
        'residential_listings.tenant_occupied', 'residential_listings.created_at',
        'residential_listings.updated_at',
        'neighborhoods.name AS neighborhood_name', 'neighborhoods.id AS neighborhood_id',
        'landlords.code',
        'landlords.id AS landlord_id',
        'users.name')

    running_list = ResidentialListing._filter_query(running_list, user, params)
    running_list
  end

  # takes in a hash of search options
  # can be formatted_street_address, landlord
  # status, unit, bed_min, bed_max, bath_min, bath_max, rent_min, rent_max,
  # neighborhoods, has_outdoor_space, features, pet_policy, ...
  def self.search(params, user, building_id=nil)
    running_list = ResidentialListing.joins(unit: {building: [:company, :landlord]})
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .joins('left join users on users.id = units.primary_agent_id')
      .where('units.archived = false')
      .where('companies.id = ?', user.company_id)
      .select('buildings.formatted_street_address',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'buildings.lat', 'buildings.lng', 'units.id AS unit_id',
        'units.building_unit', 'units.status','units.rent', 'residential_listings.beds',
        'units.primary_agent_id',
        'buildings.street_number || \' \' || buildings.route as street_address_and_unit',
        'residential_listings.id', 'residential_listings.baths','units.access_info',
        'residential_listings.favorites',
        'residential_listings.has_fee', 'residential_listings.updated_at',
        'residential_listings.tenant_occupied',
        'neighborhoods.name AS neighborhood_name', 'neighborhoods.id AS neighborhood_id',
        'landlords.code',
        'landlords.id AS landlord_id',
        'units.listing_id', 'units.available_by', 'units.public_url',
        'users.name')
    running_list = ResidentialListing._filter_query(running_list, user, params)
    running_list
  end

  def self._filter_query(running_list, user, params)
    params.delete('controller'.freeze)
    params.delete('action'.freeze)
    params.delete('format'.freeze)

    if !params && !building_id
      return running_list
    #elsif !params && building_id
      # TODO
      #running_list = running_list.where(building_id: building_id)
      #return running_list
    end

    # only admins are allowed to view off-market units
    can_view_off_market = user.is_management? ||
        user.is_listings_manager? ||
        user.is_photo_manager?
    if !can_view_off_market
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
      rent_min = params[:rent_min].to_i
      rent_max = params[:rent_max].to_i
      running_list = running_list.where("rent >= ? AND rent <= ?", rent_min, rent_max)
    elsif params[:rent_min] && !params[:rent_max]
      rent_min = params[:rent_min].to_i
      running_list = running_list.where("rent >= ?", rent_min)
    elsif !params[:rent_min] && params[:rent_max]
      rent_max = params[:rent_max].to_i
      running_list = running_list.where("rent <= ?", rent_max)
    end

    # search neighborhoods
    if params[:neighborhood_ids]
      neighborhood_ids = params[:neighborhood_ids][0, 256]
      neighborhoods = neighborhood_ids.split(",").select{|i| !i.strip.empty?}
      if neighborhoods.length > 0 # ignore empty selection
        running_list = running_list
         .where('neighborhood_id IN (?)', neighborhoods)
      end
    end

    if params[:building_feature_ids]
      features = params[:building_feature_ids][0, 256]
      features = features.split(",").select{|i| !i.empty?}
        bldg_ids = Building.joins(:building_amenities).where('building_amenity_id IN (?)', features).pluck(:id)
        running_list = running_list.where("building_id IN (?)", bldg_ids)
    end

    # search landlord code
    if params[:landlord]
      running_list = running_list
      .where("code ILIKE ?", "%#{params[:landlord]}%")
    end

    if params[:listing_id]
      running_list = running_list
      .where("units.listing_id = ?", params[:listing_id].to_i)
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
    # clean up search terms first
    params.delete('bed_min') if params[:bed_min] == 'Any'
    params.delete('bed_max') if params[:bed_max] == 'Any'
    if !params[:bed_min].blank?
      if params[:bed_min].downcase == 'studio/loft'
        params[:bed_min] = 0
      end
      running_list = running_list.where("beds >= ?", params[:bed_min])
    end
    if !params[:bed_max].blank?
      if params[:bed_max].downcase == 'studio/loft'
        params[:bed_max] = 0
      end
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

    if !params[:tenant_occupied_filter].blank?
      running_list = running_list.where(
          'residential_listings.tenant_occupied = ?', params[:tenant_occupied_filter])
    end

    # primary agent
    if !params[:primary_agent_id].blank?
      running_list = running_list.where('units.primary_agent_id = ? OR units.primary_agent2_id = ?',
        params[:primary_agent_id], params[:primary_agent_id])
    end

    running_list.uniq
  end

  def deep_copy_imgs(dst_id)
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

      #puts "NEW UNIT NUM #{residential_unit_dup.unit.building_unit}"
      residential_unit_dup
    else
      raise "No unit number, invalid unit number, or unit number already taken specified"
    end
  end

  def self.send_listings(source_agent_id, listing_ids, recipients, sub, msg)
    if source_agent_id
      UnitMailer.send_residential_listings(source_agent_id, listing_ids,
          recipients, sub, msg).deliver
    else
      "No sender specified"
    end
  end

  def send_inaccuracy_report(reporter, message)
    if reporter
      UnitMailer.inaccuracy_reported(self.id, reporter.id, message).deliver
    else
      raise "No reporter specified"
    end
  end

  def take_off_market(new_lease_end_date)
    if new_lease_end_date
      self.unit.update({status: :off, available_by: new_lease_end_date})
    else
      raise "No lease end date specified"
    end
  end

  def calc_lease_end_date
    end_date = Date.today
    end_date = Date.today >> 12
    end_date
  end

  # collect the data we will need to access from our giant map view
  def self.set_location_data(runits, images, bldg_images)
    map_infos = {}
    # speed optimizaiton. `while true` is faster than 'for ...'
    i = 0
    while true
      if i == runits.length
        break
      end

      runit = runits[i]

      if runit.street_number
        street_address = "#{runit.street_number} #{runit.route}".freeze
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
        rent: runit.rent
        }

      if bldg_images[runit.building_id]
        unit_info['image'] = bldg_images[runit.building_id]
      elsif images[runit.unit_id]
        unit_info['image'] = images[runit.unit_id]
      end

      if map_infos.has_key?(street_address)
        map_infos[street_address]['units'] << unit_info
      else
        bldg_info['units'] = [unit_info]
        map_infos[street_address] = bldg_info
      end

      i += 1
    end

    map_infos.to_json
  end

  def self.for_buildings(bldg_ids, status=nil)
    listings = ResidentialListing.joins(unit: {building: :landlord})
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .joins('left join users on users.id = units.primary_agent_id')
      .where('buildings.id in (?)', bldg_ids)
      .where('units.archived = false')
      .select('buildings.formatted_street_address',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'units.building_unit', 'units.status','units.rent', 'units.id AS unit_id',
        'residential_listings.beds', 'residential_listings.id',
        'residential_listings.baths','units.access_info',
        'residential_listings.has_fee', 'residential_listings.updated_at',
        'residential_listings.tenant_occupied',
        'neighborhoods.name AS neighborhood_name',
        'landlords.code',
        'landlords.id AS landlord_id',
        'units.primary_agent_id', 'units.available_by', 'units.listing_id',
        'users.name')
      .order('residential_listings.updated_at desc')

    if !status.nil?
      status_lowercase = status.downcase
      if status_lowercase != 'any'
        if status_lowercase == 'active/pending'
          listings = listings
              .where("units.status IN (?) ",
                [Unit.statuses['active'], Unit.statuses['pending']])
        else
          listings = listings
              .where("units.status = ? ", Unit.statuses[status_lowercase])
        end
      end
    end

    images = ResidentialListing.get_images(listings)
    bldg_images = Building.get_bldg_images_from_units(listings)
    return listings, images, bldg_images
  end

  def self.for_units(unit_ids, status=nil)
    listings = ResidentialListing.joins(unit: {building: [:landlord]})
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .joins('left join users on users.id = units.primary_agent_id')
      .where('units.id in (?)', unit_ids)
      .where('units.archived = false')
      .select('buildings.formatted_street_address',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'units.building_unit', 'units.status','units.rent', 'units.id AS unit_id',
        'residential_listings.beds', 'residential_listings.id',
        'residential_listings.baths','units.access_info',
        'residential_listings.has_fee', 'residential_listings.updated_at',
        'residential_listings.tenant_occupied',
        'neighborhoods.name AS neighborhood_name',
        'landlords.code',
        'landlords.id AS landlord_id',
        'units.primary_agent_id', 'units.available_by', 'units.listing_id',
        'users.name')

    if !status.nil?
      status_lowercase = status.downcase
      if status_lowercase != 'any'
        if status_lowercase == 'active/pending'
          listings = listings
              .where("units.status IN (?) ",
                [Unit.statuses['active'], Unit.statuses['pending']]).uniq
        else
          listings = listings
              .where("units.status = ? ", Unit.statuses[status_lowercase]).uniq
        end
      end
    end

    images = ResidentialListing.get_images(listings)
    bldg_images = Building.get_bldg_images_from_units(listings)
    return listings, images, bldg_images
  end

  # Used in our API. Takes in a list of units
  def self.get_amenities(list_of_units)
    unit_ids = list_of_units.pluck('units.id')
    list = ResidentialListing.joins(:residential_amenities)
      .where(unit_id: unit_ids).select('name', 'unit_id', 'id')
      .to_a.group_by(&:unit_id)
  end

  def can_roomshare
    if self.respond_to?(:status)
      beds >= 3 && self.status == Unit.statuses['pending']
    else
      beds >= 3 && unit.status == Unit.statuses['pending']
    end
  end

  def self.to_csv(user, params)
    listings = ResidentialListing.export_all(user, params)
    agents = Unit.get_primary_agents(listings)
    reverse_statuses = {'0': 'Active', '1': 'Pending', '2': 'Off'}

    attributes = [
      'Full Address', 'Unit', 'Neighborhood', 'Is Exclusive?', 'Roomsharing OK?',
      'Beds', 'Baths', 'Notes', 'Description', 'Lease Start', 'Lease End',
      'Has Fee?', 'OP Fee Percentage', 'TP Fee Percentage', 'Tenant Occupied',
      'Primary Agent', 'Listing ID', 'Landlord', 'Price', 'Available', 'Access',
      'Status', 'Created At', 'Updated At', 'Archived']

    CSV.generate(headers: true) do |csv|
      csv << attributes

      listings.each do |listing|
        csv << [listing.formatted_street_address, listing.building_unit, listing.neighborhood_name,
          listing.exclusive ? 'Yes' : 'No', listing.can_roomshare ? 'Yes' : 'No',
          listing.beds, listing.baths, listing.notes, listing.description, listing.lease_start,
          listing.lease_end,
          listing.has_fee ? 'Yes' : 'No', listing.op_fee_percentage, listing.tp_fee_percentage,
          listing.tenant_occupied ? 'Yes' : 'No',
          agents[listing.unit_id] ? agents[listing.unit_id].pluck(:name).join(', ') : '',
          listing.listing_id,
          listing.code,
          listing.rent,
          listing.available_by, listing.access_info,
          reverse_statuses[listing.status.to_s.to_sym],
          listing.created_at, listing.updated_at, listing.archived ? 'Yes' : 'No']
      end
    end
  end

  def set_rented_date
    self.rented_date = Date.today
    self.save
  end

  private
    def process_custom_amenities
      if custom_amenities
        amenities = custom_amenities.split(',')
        amenities.each{|a|
          if !a.empty?
            a = a.downcase.strip
            found = ResidentialAmenity.where(name: a, company: self.unit.building.company).first
            if !found
              self.residential_amenities << ResidentialAmenity.create!(name: a, company: self.unit.building.company)
            end
          end
        }
      end
    end

    def update_building_counts
      bldg = self.unit.building
      bldg.update_total_unit_count
      bldg.update_active_unit_count
      bldg.last_unit_updated_at = DateTime.now

      bldg.landlord.update_total_unit_count
      bldg.landlord.update_active_unit_count
      bldg.landlord.last_unit_updated_at = DateTime.now
    end

end
