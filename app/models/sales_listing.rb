class SalesListing < ApplicationRecord
  audited except: [:created_at, :updated_at]

	scope :unarchived, ->{where(archived: false)}
  has_and_belongs_to_many :sales_amenities
  belongs_to :unit, touch: true
  before_save :process_custom_amenities
  after_commit :update_building_counts, :trim_audit_log

  # NOTE: because our accessors clobber the names of some of our
  # building's fields, we reference the intended names here, but change
  # the names in our search method defined below.
  attr_accessor :include_photos, :inaccuracy_description,
    :available_starting, :available_before, :custom_amenities,
    :street_number, :route, :intersection,
    :neighborhood, :lat, :lng,
    :sublocality, :administrative_area_level_2_short,
    :administrative_area_level_1_short,
    :postal_code, :country_short,
    :place_id, :formatted_street_address

  VALID_TELEPHONE_REGEX = /\A(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?\z/

  validates :seller_name, presence: true, length: {maximum: 500}
  validates :seller_phone, allow_blank: true, length: {maximum: 25},
    format: { with: VALID_TELEPHONE_REGEX }

	validates :seller_address, presence: true, length: {maximum: 500}
  validates :listing_type, presence: true, length: {maximum: 100}
  validates :listing_name, presence: { message: "You must provide the Building Name." } #true, message: 'You must provide the Building Name.'
	#validates :beds, presence: true, :numericality => { :less_than_or_equal_to => 11 }
	#validates :baths, presence: true, :numericality => { :less_than_or_equal_to => 11 }
  validates :total_room_count, presence: true
  def archive
    self.unit.archived = true
    self.unit.save
    self.update_building_counts
  end

  def self.find_unarchived(id)
    SalesListing.joins(:unit)
      .where(id: id)
      .where('units.archived = false')
      .first
  end

  # used as a sorting condition
  def street_address_and_unit
    output = ""
     # calling from 'show', for example with full objects loaded
    if !self.respond_to? :street_number2
      if unit.building.street_number
        output = unit.building.street_number + ' ' + unit.building.route
      end

      if !unit.building_unit.blank?
        output = output + ' #' + unit.building_unit
      end
    else # otherwise, we used a select statement to cherry pick fields
      if street_number2
        output = street_number2 + ' ' + route2
      end

      if !building_unit.blank?
        output = output + " #" + building_unit
      end
    end

    output
  end

  def street_address
    output = ""
     # calling from 'show', for example with full objects loaded
    if !self.respond_to? :street_number2
      if unit.building.street_number
        output = unit.building.street_number + ' ' + unit.building.route
      end

    else # otherwise, we used a select statement to cherry pick fields
      if street_number2
        output = street_number2 + ' ' + route2
      end
    end

    output
  end

  def amenities_to_s
    amenities = sales_amenities.map{|a| a.name.titleize}
    amenities ? amenities.join(", ") : "None"
  end

  def all_amenities_to_s
    bldg_amenities = unit.building.building_amenities.map{|a| a.name.titleize}
    amenities = sales_amenities.map{|a| a.name.titleize}
    amenities.concat(bldg_amenities)
    amenities ? amenities.join(", ") : "None"
  end

  # returns the first image for each unit
  def self.get_images(list)
    imgs = Image.where(unit_id: list.pluck('units.id'), priority: 0)
    Hash[imgs.map {|img| [img.unit_id, img.file.url(:thumb)]}]
  end

  def self.get_amenities(list)
    SalesAmenity.where(sales_listing_id: list.ids)
        .select('name').to_a.group_by(&:sales_listing_id)
  end

  def self.listings_by_neighborhood(user, listing_ids)
    running_list = SalesListing.joins(unit: {building: [:company]})
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .where('companies.id = ?', user.company_id)
      .where('units.listing_id IN (?)', listing_ids)
      .select('buildings.formatted_street_address AS formatted_street_address2',
        'units.listing_id',
        'buildings.id AS building_id', 'buildings.street_number as street_number2', 'buildings.route as route2',
        'buildings.lat as lat2', 'buildings.lng as lng2', 'units.id AS unit_id',
        'units.building_unit', 'units.status','units.rent',
        'sales_listings.beds || \'/\' || sales_listings.baths as bed_and_baths',
        'buildings.street_number || \' \' || buildings.route as street_address_and_unit',
        'units.access_info',
        'sales_listings.id', 'sales_listings.baths', 'sales_listings.beds', 'units.access_info',
        'sales_listings.seller_name', 'sales_listings.updated_at',
        'neighborhoods.name AS neighborhood_name', 'neighborhoods.id AS neighborhood_id',
        'units.available_by', 'units.public_url')
      .to_a.group_by(&:neighborhood_name)
    running_list
  end

  def self.listings_by_id(user, listing_ids)
    running_list = SalesListing.joins(unit: {building: [:company]})
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .where('companies.id = ?', user.company_id)
      .where('units.listing_id IN (?)', listing_ids)
      .select('buildings.formatted_street_address AS formatted_street_address2',
        'units.listing_id',
        'buildings.id AS building_id', 'buildings.street_number as street_number2', 'buildings.route as route2',
        'buildings.lat as lat2', 'buildings.lng as lng2', 'units.id AS unit_id',
        'units.building_unit', 'units.status','units.rent',
        'sales_listings.beds || \'/\' || sales_listings.baths as bed_and_baths',
        'buildings.street_number || \' \' || buildings.route as street_address_and_unit',
        'units.access_info',
        'sales_listings.id', 'sales_listings.baths', 'sales_listings.beds', 'units.access_info',
        'sales_listings.seller_name', 'sales_listings.updated_at',
        'neighborhoods.name AS neighborhood_name', 'neighborhoods.id AS neighborhood_id',
        'units.available_by', 'units.public_url',
        'users.name as primary_agent_name')

    running_list
  end

  def self.export_all(user)
    SalesListing.joins(unit: [building: [:company]])
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .where('units.archived = false')
      .where('companies.id = ?', user.company_id)
      .select('buildings.formatted_street_address AS formatted_street_address2',
        'units.listing_id',
        'buildings.id AS building_id', 'buildings.street_number as street_number2', 'buildings.route as route2',
        'buildings.lat as lat2', 'buildings.lng as lng2', 'units.id AS unit_id',
        'units.building_unit', 'units.status', 'units.rent', 'units.exclusive',
        'units.primary_agent_id', 'units.primary_agent2_id',
        'sales_listings.beds || \'/\' || sales_listings.baths as bed_and_baths',
        'buildings.street_number || \' \' || buildings.route as street_address_and_unit',
        'units.access_info', 'sales_listings.internal_notes', 'sales_listings.public_description',
        'sales_listings.tenant_occupied', 'sales_listings.listing_type', 'sales_listings.percent_commission',
        'sales_listings.outside_broker_commission', 'sales_listings.seller_phone', 'sales_listings.seller_address',
        'sales_listings.id', 'sales_listings.baths', 'sales_listings.beds', 'sales_listings.year_built',
        'sales_listings.building_type', 'sales_listings.lot_size', 'sales_listings.building_size',
        'sales_listings.block_taxes', 'sales_listings.lot_taxes', 'sales_listings.water_sewer','sales_listings.insurance',
        'sales_listings.school_district', 'sales_listings.certificate_of_occupancy', 'sales_listings.violation_search',
        'units.access_info',
        'sales_listings.seller_name', 'sales_listings.created_at', 'sales_listings.updated_at',
        'units.archived',
        'neighborhoods.name AS neighborhood_name', 'neighborhoods.id AS neighborhood_id',
        'units.available_by', 'units.public_url')
  end

  # takes in a hash of search options
  def self.search(params, user, building_id=nil)
    # TODO: add amenities back in
    # 'building_amenities.name AS bldg_amenity_name',
    @running_list = SalesListing.joins(unit: [building: [:company]])
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .where('units.archived = false')
      .where('companies.id = ?', user.company_id)
      .select('units.listing_id', 'buildings.formatted_street_address AS formatted_street_address2',
        'buildings.id AS building_id', 'buildings.street_number as street_number2', 'buildings.route as route2',
        'buildings.lat as lat2', 'buildings.lng as lng2', 'units.id AS unit_id',
        'units.building_unit', 'units.status','units.rent',
        'sales_listings.beds || \'/\' || sales_listings.baths as bed_and_baths',
        'buildings.street_number || \' \' || buildings.route as street_address_and_unit',
        'units.access_info', 'sales_listings.lot_size',
        'sales_listings.id', 'sales_listings.baths', 'sales_listings.beds', 'units.access_info',
        'sales_listings.seller_name', 'sales_listings.updated_at',
        'neighborhoods.name AS neighborhood_name', 'neighborhoods.id AS neighborhood_id',
        'units.available_by', 'units.public_url')

    if !params && !building_id
      return @running_list
    elsif !params && building_id
      @running_list = @running_list.where(building_id: building_id)
      return @running_list
    end

    # only admins are allowed to view off-market units
    if !user.is_management?
     @running_list = @running_list.where.not('status = ?', Unit.statuses['off'])
    end

    # all search params come in as strings from the url
    # clear out any invalid search params
    params.delete_if{ |k,v| (!v || v == 0 || v.empty?) }

    # search by address (building)
    if params[:address]
      # cap query string length for security reasons
      address = params[:address][0, 500]
      @running_list =
        @running_list.where('buildings.formatted_street_address ILIKE ?', "%#{address}%")
    end

    # search by unit
    if params[:unit]
      # cap query string length for security reasons
      address = params[:unit][0, 50]
      @running_list = @running_list.where("building_unit ILIKE ?", "%#{params[:unit]}%")
    end

    # search by status
    if params[:status]
      status = params[:status].downcase
      included = ['active', 'on market', 'contract out', 'inescrow', 'closed'].include?(status)
      if included
        @running_list = @running_list.where("status = ?", Unit.statuses[status])
      end
    end

    # search by rent
    if params[:rent_min] && params[:rent_max]
      rent_min = params[:rent_min].to_i
      rent_max = params[:rent_max].to_i
      @running_list = @running_list.where("rent >= ? AND rent <= ?", rent_min, rent_max)
    elsif params[:rent_min] && !params[:rent_max]
      rent_min = params[:rent_min].to_i
      @running_list = @running_list.where("rent >= ?", rent_min)
    elsif !params[:rent_min] && params[:rent_max]
      rent_max = params[:rent_max].to_i
      @running_list = @running_list.where("rent <= ?", rent_max)
    end

    # search neighborhoods
    if params[:neighborhood_ids]
      neighborhood_ids = params[:neighborhood_ids][0, 256]
      neighborhoods = neighborhood_ids.split(",").select{|i| !i.strip.empty?}
      #puts "**** #{neighborhoods.inspect}"
      if neighborhoods.length > 0 # ignore empty selection
        @running_list = @running_list
         .where('neighborhood_id IN (?)', neighborhoods)
      end
    end

    if params[:building_feature_ids]
      features = params[:building_feature_ids][0, 256]
      features = features.split(",").select{|i| !i.empty?}
        bldg_ids = Building.joins(:building_amenities).where('building_amenity_id IN (?)', features).ids
        @running_list = @running_list.where("building_id IN (?)", bldg_ids)
    end

    if params[:available_starting] || params[:available_before]
      if params[:available_starting] && !params[:available_starting].empty?
        @running_list = @running_list.where('available_by > ?', params[:available_starting]);
      end
      if params[:available_before] && !params[:available_before].empty?
        @running_list = @running_list.where('available_by < ?', params[:available_before]);
      end
    end

    # search beds
    if params[:bed_min] && params[:bed_max]
      @running_list = @running_list.where("beds >= ? AND beds <= ?", params[:bed_min], params[:bed_max])
    elsif params[:bed_min] && !params[:bed_max]
      @running_list = @running_list.where("beds >= ?", params[:bed_min])
    elsif !params[:bed_min] && params[:bed_max]
      @running_list = @running_list.where("beds <= ?", params[:bed_max])
    end

    # search baths
    if params[:bath_min] && params[:bath_max]
      @running_list = @running_list.where("baths >= ? AND baths <= ?", params[:bath_min], params[:bath_max])
    elsif params[:bath_min] && !params[:bath_max]
      @running_list = @running_list.where("baths >= ?", params[:bath_min])
    elsif !params[:bath_min] && params[:bath_max]
      @running_list = @running_list.where("baths <= ?", params[:bath_max])
    end

    @running_list
  end

  # TODO: run this in the background. See Image class for stub
  def deep_copy_imgs(dst_id)
    #puts "YEAAAAAA MAN #{src_id} #{dst_id}"
    #@src = SalesListing.find(src_id)
    @dst = SalesListing.find(dst_id)

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

        sales_unit_dup = self.dup
        sales_unit_dup.update(unit_id: unit_dup.id)

        self.sales_amenities.each {|a|
          sales_unit_dup.sales_amenities << a
        }
      else
        raise "Error saving unit"
      end

      #Image.async_copy_sales_unit_images(self.id, sales_unit_dup.id)
      if include_photos
        self.deep_copy_imgs(sales_unit_dup.id)
      end

      #building.increment_memcache_iterator
      #puts "NEW UNIT NUM #{sales_unit_dup.unit.building_unit}"
      sales_unit_dup
    else
      raise "No unit number, invalid unit number, or unit number already taken specified"
    end
  end

  def self.send_listings(source_agent_id, listing_id, recipients, sub, msg)
    if source_agent_id
      UnitMailer.send_sales_listings(source_agent, listing_ids, recipients, sub, msg).deliver
    else
      "No sender specified"
    end
  end

  def send_inaccuracy_report(reporter, message, price_drop_request)
    if reporter && (!message.blank? || price_drop_request)
      Feedback.create!({
        user_id: reporter.id,
        unit_id: self.id,
        description: message,
        price_drop_request: price_drop_request
      })
      UnitMailer.inaccuracy_reported(self.id, reporter.id, message, price_drop_request).deliver
    else
      raise "Invalid params specified while sending feedback"
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

  # collect the data we will need to access from our giant map view
  def self.set_location_data(runits, images)
    map_infos = {}
    # speed optimizaiton. `while true` is faster than 'for ...'
    i = 0
    while true
      if i == runits.length
        break
      end
      runit = runits[i]

      if runit.street_number2
        street_address = runit.street_number2 + ' ' + runit.route2
      else
        street_address = runit.route2
      end

      bldg_info = {
        building_id: runit.building_id,
        lat: runit.lat2,
        lng: runit.lng2 }
      unit_info = {
        id: runits[i].id,
        building_unit: runit.building_unit,
        beds: runit.beds,
        baths: runit.baths,
        rent: runit.rent }

      if images[runit.unit_id]
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

  def self.for_buildings(bldg_ids, is_active=nil)
    listings = SalesListing.joins(unit: :building)
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .where('buildings.id in (?)', bldg_ids)
      .where('units.archived = false')
      .select('buildings.formatted_street_address AS formatted_street_address2',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'units.building_unit', 'units.status','units.rent', 'units.id AS unit_id',
        'beds || \'/\' || baths as bed_and_baths',
        'sales_listings.beds', 'sales_listings.id',
        'sales_listings.baths','units.access_info',
        'sales_listings.updated_at',
        'neighborhoods.name AS neighborhood_name',
        'units.available_by')

    if is_active
      listings = listings.where.not("status = ?", Unit.statuses["off"])
    end

    unit_ids = listings.pluck(:unit_id)
    images = Image.where(unit_id: unit_ids).index_by(&:unit_id)

    return listings, images
  end

  def self.for_units(unit_ids, is_active=nil)
    listings = SalesListing.joins(unit: :building)
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .where('units.id in (?)', unit_ids)
      .where('units.archived = false')
      .select('buildings.formatted_street_address AS formatted_street_address2',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'units.building_unit', 'units.status','units.rent', 'units.id AS unit_id',
        'beds || \'/\' || baths as bed_and_baths',
        'sales_listings.beds', 'sales_listings.id',
        'sales_listings.baths','units.access_info',
        'sales_listings.updated_at',
        'neighborhoods.name AS neighborhood_name',
        'units.available_by')

    if is_active
      listings = listings.where.not("status = ?", Unit.statuses["off"])
    end

    unit_ids = listings.pluck(:unit_id)
    images = Image.where(unit_id: unit_ids).index_by(&:unit_id)

    return listings, images
  end

  # Used in our API. Takes in a list of units
  def self.get_amenities(list_of_units)
    unit_ids = list_of_units.pluck('units.id')
    list = SalesListing.joins(:sales_amenities)
      .where(unit_id: unit_ids).select('name', 'unit_id', 'id')
      .to_a.group_by(&:unit_id)
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
            found = SalesAmenity.where(name: a, company: self.unit.building.company).first
            if !found
              self.sales_amenities << SalesAmenity.create!(name: a, company: self.unit.building.company)
            end
          end
        }
      end
    end

    def update_building_counts
      bldg = self.unit.building
      bldg.update_total_unit_count
      bldg.update_active_unit_count
    end

    def trim_audit_log
      # to keep updates speedy, we cap the audit log at 100 entries per record
      audits_count = audits.length
      if audits_count > 50
        audits.first.destroy
      end

      # we also discard the initial audit record, which is triggered upon creation
      if audits_count > 0 && audits.first.created_at.to_time.to_i == self.created_at.to_time.to_i
        audits.first.update(comment: 'created')
      end
    end
end
