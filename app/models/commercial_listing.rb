class CommercialListing < ActiveRecord::Base
  scope :unarchived, ->{where(archived: false)}
  belongs_to :commercial_property_type
  belongs_to :unit, touch: true
  has_many :documents, dependent: :destroy
  #belongs_to :primary_agent2, :class_name => 'User', touch: true

  attr_accessor :property_type, :inaccuracy_description, :sq_footage_min, :sq_footage_max

  enum construction_status: [ :existing, :under_construction ]
  validates :construction_status, presence: true, inclusion: { in: %w(existing under_construction) }
  
  enum lease_type: [ :na, :full_service, :nnn, :modified_gross, :modified_net, :industrial_gross, :other ]
  validates :lease_type, presence: true, inclusion: { in: %w(na full_service nnn modified_gross modified_net industrial_gross other) }
  
	#validates :sq_footage, presence: true, :numericality => { :less_than_or_equal_to => 99999999 }
	#validates :floor, presence: true, :numericality => { :less_than_or_equal_to => 999 }
	validates :building_size, presence: true, :numericality => { :less_than_or_equal_to => 99999999 }
  validates :total_lot_size, presence: true

  validates :property_description, presence: true
  validates :location_description, presence: true


  def archive
    self.unit.archived = true
    self.unit.save
  end

  def self.find_unarchived(id)
    CommercialListing.joins(unit: [building: [:landlord, :neighborhood]])
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
    end
    output
  end

  def summary
  	summary = property_category
  	if property_sub_type
  		summary += ' (' + property_sub_type + ')'
  	end

  	summary
  end

  def price_per_sq_ft
    if ! unit.rent.to_f || !sq_footage
      '0'
    else
      unit.rent.to_f / sq_footage
    end
  end

  # for use in search method below
  # returns the first image for each unit
  def self.get_images(list)
    unit_ids = list.map(&:unit_id)
    Image.where(unit_id: unit_ids, priority: 0).index_by(&:unit_id)
  end

   def self.export_all(user)
    CommercialListing.joins([:commercial_property_type, unit: [:primary_agent, building: [:company, :landlord, :neighborhood]]])
      .where('companies.id = ?', user.company_id)
      .select('buildings.formatted_street_address', 
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route', 

        'buildings.lat', 'buildings.lng', 'units.listing_id', 'units.access_info', 'units.listing_id',
        'units.building_unit', 'units.status','units.rent', 'units.available_by','units.exclusive',
        'commercial_listings.sq_footage', 'commercial_listings.floor', 'commercial_listings.building_size', 
        'commercial_listings.build_to_suit', 'commercial_listings.minimum_divisible', 'commercial_listings.maximum_contiguous', 
        'commercial_listings.lease_type', 'commercial_listings.is_sublease', 'commercial_listings.listing_title', 
        'commercial_listings.property_description', 'commercial_listings.location_description', 
        'commercial_listings.construction_status', 'commercial_listings.lease_term_months', 'commercial_listings.rate_is_negotiable', 
        'commercial_listings.total_lot_size', 
        'commercial_listings.liquor_eligible', 'commercial_listings.has_basement', 'commercial_listings.basement_sq_footage', 
        'commercial_listings.has_ventilation', 'commercial_listings.key_money_required', 'commercial_listings.key_money_amt',
        'commercial_listings.created_at','commercial_listings.updated_at', 'units.archived', 
        'neighborhoods.name AS neighborhood_name', 
        'landlords.code AS landlord_code','landlords.id AS landlord_id',
        "commercial_property_types.property_type AS property_category", "commercial_property_types.property_sub_type",
        'users.name as primary_agent_name'
        )
    end
  
  def self.search(params, user, building_id=nil)
    @running_list = CommercialListing.joins([:commercial_property_type, unit: {building: [:company, :landlord, :neighborhood]}])
      .where('units.archived = false')
      .where('companies.id = ?', user.company_id)
      .select('buildings.formatted_street_address', 
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route', 
        'buildings.lat', 'buildings.lng', 'units.id AS unit_id', 'units.access_info', 'units.listing_id',
        'units.building_unit', 'units.status','units.rent', 'commercial_listings.sq_footage', 
        'commercial_listings.id', 'commercial_listings.updated_at', 
        'neighborhoods.name AS neighborhood_name', 
        'landlords.code AS landlord_code','landlords.id AS landlord_id',
        "commercial_property_types.property_type AS property_category", "commercial_property_types.property_sub_type",
        'units.available_by')

    # actable_type to restrict to commercial only
    if !params && !building_id
      return @running_list
    elsif !params && building_id
      @running_list.where(building_id: building_id)
      return @running_list
    end

    # only admins are allowed to view off-market units
    if !user.is_management?
     @running_list = @running_list.where.not('status = ?', Unit.statuses['off'])
    end
    
    # clear out any invalid search params
    #params.delete_if{|k,v| !(v || v > 0 || !v.empty?) }
    params.delete_if{|k,v| (!v || v == 0 || v.empty?) }

    # search by address (building)
    if params[:address]
      # cap query string length for security reasons
      address = params[:address][0, 500]
      @running_list = 
       @running_list.where('buildings.formatted_street_address ILIKE ?', "%#{address}%")
    end

    # search by status
    if params[:status]
      status = params[:status].downcase.gsub(/ /, '_')
      included = ['active', 'offer_submitted', 'offer_accepted', 'binder_signed', 'off_market_for_lease_execution', 'off'].include?(status)
      if included
        @running_list = @running_list.where("status = ?", Unit.statuses[status])
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
      neighborhoods = neighborhood_ids.split(",").select{|i| !i.empty?}
      @running_list = @running_list
       .where('neighborhood_id IN (?)', neighborhoods)
    end

    # search landlord code
    if params[:landlord]
      @running_list = @running_list
      .where("code ILIKE ?", "%#{params[:landlord]}%")
    end

    # sq footage
    if params[:sq_footage_min] && params[:sq_footage_max]
      @running_list = @running_list.where("sq_footage >= ? AND sq_footage <= ?", params[:sq_footage_min], params[:sq_footage_max])
    elsif params[:sq_footage_min] && !params[:sq_footage_max]
      @running_list = @running_list.where("sq_footage >= ?", params[:sq_footage_min])
    elsif !params[:sq_footage_min] && params[:sq_footage_max]
      @running_list = @running_list.where("sq_footage <= ?", params[:sq_footage_max])
    end

    # search landlord code
    if params[:commercial_property_type_id]
      @running_list = @running_list
      .where("commercial_property_type_id = ?", params[:commercial_property_type_id])
    end
      
    return @running_list
  end

  # TODO: run this in the background. See Image class for stub
  def deep_copy_imgs(dst_id)
    #puts "YEAAAAAA MAN #{src_id} #{dst_id}"
    @dst = CommercialListing.find(dst_id)

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
        unit_dup.save
        commercial_unit_dup = self.dup
        commercial_unit_dup.unit = unit_dup
        commercial_unit_dup.save

        #Image.async_copy_commercial_unit_images(self.id, residential_unit_dup.id)
        if include_photos
          self.deep_copy_imgs(commercial_unit_dup.id)
        end
        commercial_unit_dup
    else
      raise "No unit number, invalid unit number, or unit number already taken specified"
    end
  end

  def self.send_listings(source_agent, listings, images, recipients, sub, msg)
    if source_agent
      UnitMailer.send_commercial_listings(source_agent, listings, images, recipients, sub, msg).deliver_now
    else
      "No sender specified"
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
      #bldg = cunits[i].unit.building
      cunit = cunits[i]
      street_address = cunit.street_number + " " + cunit.route
      bldg_info = {
        building_id: cunit.building_id,
        lat: cunit.lat, 
        lng: cunit.lng }
      unit_info = {
        id: cunits[i].id,
        building_unit: cunits[i].building_unit,
        rent: cunits[i].rent,
        property_type: cunits[i].property_sub_type,
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

  def self.for_buildings(bldg_ids, is_active=nil)
    listings = CommercialListing.joins([:commercial_property_type, unit: {building: [:company, :landlord, :neighborhood]}])
      .where('units.archived = false')
      .where('buildings.id in (?)', bldg_ids)
      .select('buildings.formatted_street_address', 
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route', 
        'buildings.lat', 'buildings.lng', 'units.id AS unit_id','units.access_info', 'units.listing_id',
        'units.building_unit', 'units.status','units.rent', 'commercial_listings.sq_footage', 
        'commercial_listings.id', 'commercial_listings.updated_at', 
        'neighborhoods.name AS neighborhood_name', 
        'landlords.code AS landlord_code','landlords.id AS landlord_id',
        "commercial_property_types.property_type AS property_category", "commercial_property_types.property_sub_type",
        'units.available_by')
      
    if is_active
      listings = listings.where.not("status = ?", Unit.statuses["off"])
    end
    
    unit_ids = listings.map(&:unit_id)
    images = Image.where(unit_id: unit_ids).index_by(&:unit_id)
      
    return listings, images
  end

  def self.listings_by_neighborhood(user, listing_ids)
    running_list = CommercialListing.joins([:commercial_property_type, unit: {building: [:company, :landlord, :neighborhood]}])
      .where('companies.id = ?', user.company_id)
      .where('units.listing_id IN (?)', listing_ids)
      .select('buildings.formatted_street_address', 
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route', 
        'buildings.lat', 'buildings.lng', 'units.id AS unit_id', 'units.access_info', 'units.listing_id',
        'units.building_unit', 'units.status','units.rent', 'commercial_listings.sq_footage', 
        'commercial_listings.id', 'commercial_listings.updated_at', 
        'neighborhoods.name AS neighborhood_name', 
        'landlords.code AS landlord_code','landlords.id AS landlord_id',
        "commercial_property_types.property_type AS property_category", "commercial_property_types.property_sub_type",
        'units.available_by')
      .to_a.group_by(&:neighborhood_name)
    running_list
  end

  def self.for_units(unit_ids, is_active=nil)
    listings = CommercialListing.joins([:commercial_property_type, unit: {building: [:company, :landlord, :neighborhood]}])
      .where('units.archived = false')
      .where('units.id in (?)', unit_ids)
      .select('buildings.formatted_street_address', 
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route', 
        'buildings.lat', 'buildings.lng', 'units.id AS unit_id', 'units.access_info','units.listing_id',
        'units.building_unit', 'units.status','units.rent', 'commercial_listings.sq_footage', 
        'commercial_listings.id', 'commercial_listings.updated_at', 
        'neighborhoods.name AS neighborhood_name', 
        'landlords.code AS landlord_code','landlords.id AS landlord_id',
        "commercial_property_types.property_type AS property_category", "commercial_property_types.property_sub_type",
        'units.available_by')
      
    if is_active
      listings = listings.where.not("status = ?", Unit.statuses["off"])
    end
    
    unit_ids = listings.map(&:unit_id)
    images = Image.where(unit_id: unit_ids).index_by(&:unit_id)
      
    return listings, images
  end

  def self.listings_by_id(user, listing_ids)
    running_list = CommercialListing.joins([:commercial_property_type, unit: {building: [:company, :landlord, :neighborhood]}])
      .where('companies.id = ?', user.company_id)
      .where('units.listing_id IN (?)', listing_ids)
      .where('units.archived = false')
      .select('buildings.formatted_street_address', 
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route', 
        'buildings.lat', 'buildings.lng', 'units.id AS unit_id', 'units.access_info',
        'units.building_unit', 'units.status','units.rent', 'commercial_listings.sq_footage', 
        'commercial_listings.id', 'commercial_listings.updated_at', 
        'neighborhoods.name AS neighborhood_name', 
        'landlords.code AS landlord_code','landlords.id AS landlord_id',
        "commercial_property_types.property_type AS property_category", "commercial_property_types.property_sub_type",
        'units.available_by')
    running_list
  end

end