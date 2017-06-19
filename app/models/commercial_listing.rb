class CommercialListing < ApplicationRecord
  audited except: [:created_at, :updated_at]

  scope :unarchived, ->{where(archived: false)}
  belongs_to :commercial_property_type
  belongs_to :unit, touch: true
  has_many :documents, dependent: :destroy
  #belongs_to :primary_agent2, :class_name => 'User', touch: true
  after_commit :update_building_counts, :trim_audit_log

  attr_accessor :property_type, :inaccuracy_description, :sq_footage_min, :sq_footage_max

  enum construction_status: [ :existing, :under_construction ]
  validates :construction_status, presence: true, inclusion: { in: %w(existing under_construction) }

  enum lease_type: [ :na, :full_service, :nnn, :modified_gross, :modified_net, :industrial_gross, :other ]
  validates :lease_type, presence: true, inclusion: { in: %w(na full_service nnn modified_gross modified_net industrial_gross other) }

	validates :building_size, presence: true, :numericality => { :less_than_or_equal_to => 99999999 }
  validates :total_lot_size, presence: true

  validates :property_description, presence: true

  def archive
    self.unit.archived = true
    self.unit.save
    update_building_counts
  end

  def self.find_unarchived(id)
    # .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')

    CommercialListing.joins(unit: [building: :landlord])
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

      if !unit.building_unit.blank?
        output = output + ' #' + unit.building_unit
      end
    else # otherwise, we used a select statement to cherry pick fields
      if street_number
        output = street_number + ' ' + route
      end

      if !building_unit.blank?
        output = output + " #" + building_unit
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

  # returns the first image for each unit
  def self.get_images(list)
    imgs = Image.where(unit_id: list.pluck(:unit_id), priority: 0)
    Hash[imgs.map {|img| [img.unit_id, img.file.url(:thumb)]}]
  end

  def self.export_all(user, params)
    # params = params.symbolize_keys
    running_list = CommercialListing
      .joins([:commercial_property_type, unit: [building: [:company, :landlord]]])
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .where('companies.id = ?', user.company_id)
      .select('buildings.formatted_street_address',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'buildings.lat', 'buildings.lng', 'units.id as unit_id', 'units.listing_id',
        'units.access_info', 'units.listing_id',
        'units.building_unit', 'units.status','units.rent', 'units.available_by','units.exclusive',
        'units.primary_agent_id', 'units.primary_agent2_id',
        'commercial_listings.sq_footage', 'commercial_listings.floor',
        'commercial_listings.building_size',
        'commercial_listings.build_to_suit', 'commercial_listings.minimum_divisible',
        'commercial_listings.maximum_contiguous',
        'commercial_listings.lease_type', 'commercial_listings.is_sublease',
        'commercial_listings.listing_title',
        'commercial_listings.property_description', 'commercial_listings.location_description',
        'commercial_listings.construction_status', 'commercial_listings.lease_term_months',
        'commercial_listings.rate_is_negotiable',
        'commercial_listings.total_lot_size',
        'commercial_listings.liquor_eligible', 'commercial_listings.has_basement',
        'commercial_listings.basement_sq_footage',
        'commercial_listings.has_ventilation', 'commercial_listings.key_money_required',
        'commercial_listings.key_money_amt',
        'commercial_listings.created_at','commercial_listings.updated_at', 'units.archived',
        'neighborhoods.name AS neighborhood_name',
        #'landlords.code AS landlord_code',
        'landlords.code',
        'landlords.id AS landlord_id',
        'commercial_property_types.property_type AS property_category',
        'commercial_property_types.property_sub_type',
        )

    running_list = CommercialListing._filter_query(running_list, user, params)
    running_list
  end

  def self.search(params, user, building_id=nil)
    running_list = CommercialListing.joins([:commercial_property_type, unit: {building: [:company, :landlord]}])
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .where('units.archived = false')
      .where('companies.id = ?', user.company_id)
      .select('buildings.formatted_street_address',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'buildings.lat', 'buildings.lng', 'units.id AS unit_id', 'units.access_info', 'units.listing_id',
        'units.building_unit', 'units.status','units.rent', 'commercial_listings.sq_footage',
        'commercial_listings.id', 'commercial_listings.updated_at',
        'neighborhoods.name AS neighborhood_name',
        #'landlords.code AS landlord_code',
        'landlords.code',
        'landlords.id AS landlord_id',
        "commercial_property_types.property_type AS property_category", "commercial_property_types.property_sub_type",
        'units.available_by', 'units.primary_agent_id', 'units.primary_agent2_id')

    running_list = CommercialListing._filter_query(running_list, user, params)
    running_list
  end

  def self._filter_query(running_list, user, params)
    # actable_type to restrict to commercial only
    if !params && !building_id
      return running_list
    elsif !params && building_id
      running_list.where(building_id: building_id)
      return running_list
    end

    # only admins are allowed to view off-market units
    if !user.is_management?
     running_list = running_list.where.not('status = ?', Unit.statuses['off'])
    end

    # clear out any invalid search params
    #params.delete_if{|k,v| !(v || v > 0 || !v.empty?) }
    params.delete_if{|k,v| (!v || v == 0 || v.empty?) }

    # search by address (building)
    if params[:address]
      # cap query string length for security reasons
      address = params[:address][0, 500]
      running_list =
       running_list.where('buildings.formatted_street_address ILIKE ?', "%#{address}%")
    end

    # search by status
    if params[:status]
      status = params[:status].downcase.gsub(/ /, '_')
      included = ['active', 'offer_submitted', 'offer_accepted', 'binder_signed', 'off_market_for_lease_execution', 'off'].include?(status)
      if included
        running_list = running_list.where("status = ?", Unit.statuses[status])
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
      neighborhoods = neighborhood_ids.split(",").select{|i| !i.empty?}
      running_list = running_list
       .where('neighborhood_id IN (?)', neighborhoods)
    end

    # search landlord code
    if params[:landlord]
      running_list = running_list
      .where("code ILIKE ?", "%#{params[:landlord]}%")
    end

    # sq footage
    if params[:sq_footage_min] && params[:sq_footage_max]
      running_list = running_list.where("sq_footage >= ? AND sq_footage <= ?", params[:sq_footage_min], params[:sq_footage_max])
    elsif params[:sq_footage_min] && !params[:sq_footage_max]
      running_list = running_list.where("sq_footage >= ?", params[:sq_footage_min])
    elsif !params[:sq_footage_min] && params[:sq_footage_max]
      running_list = running_list.where("sq_footage <= ?", params[:sq_footage_max])
    end

    # search landlord code
    if params[:commercial_property_type_id]
      running_list = running_list
      .where("commercial_property_type_id = ?", params[:commercial_property_type_id])
    end

    # primary agent
    if !params[:primary_agent_id].blank?
      running_list = running_list.where('units.primary_agent_id = ? OR units.primary_agent2_id = ?',
        params[:primary_agent_id], params[:primary_agent_id])
    end

    return running_list
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

  def self.send_listings(source_agent_id, listing_ids, recipients, sub, msg)
    if source_agent_id
      UnitMailer.send_commercial_listings(source_agent_id, listing_ids, recipients,
          sub, msg).deliver
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
      UnitMailer.commercial_inaccuracy_reported(self.id, reporter.id, message).deliver
    else
      raise "Invalid params specified while sending feedback"
    end
  end

  # collect the data we will need to access from our giant map view
  def self.set_location_data(cunits, images, bldg_images)
    map_infos = {}
    i = 0
    while true
      if i == cunits.length
        break
      end

      cunit = cunits[i]
      street_address = cunit.street_number + " " + cunit.route
      bldg_info = {
        building_id: cunit.building_id,
        lat: cunit.lat,
        lng: cunit.lng }
      unit_info = {
        id: cunit.id,
        building_unit: cunit.building_unit,
        rent: cunit.rent,
        property_type: cunit.property_category,
        sq_footage: cunit.sq_footage
       }

      if bldg_images[cunit.building_id]
        unit_info['image'] = bldg_images[cunit.building_id]
      elsif images[cunit.unit_id]
        unit_info['image'] = images[cunit.unit_id]
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
    listings = CommercialListing.joins([:commercial_property_type, unit: {building: [:company, :landlord]}])
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .where('units.archived = false')
      .where('buildings.id in (?)', bldg_ids)
      .select('buildings.formatted_street_address',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'buildings.lat', 'buildings.lng', 'units.id AS unit_id','units.access_info', 'units.listing_id',
        'units.building_unit', 'units.status','units.rent', 'commercial_listings.sq_footage',
        'commercial_listings.id', 'commercial_listings.updated_at',
        'neighborhoods.name AS neighborhood_name',
        'landlords.code',
        'landlords.id AS landlord_id',
        "commercial_property_types.property_type AS property_category", "commercial_property_types.property_sub_type",
        'units.available_by')
      .order('commercial_listings.updated_at desc')

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

    images = CommercialListing.get_images(listings)
    bldg_images = Building.get_bldg_images_from_units(listings)
    return listings, images, bldg_images
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
        #'landlords.code AS landlord_code',
        'landlords.code',
        'landlords.id AS landlord_id',
        "commercial_property_types.property_type AS property_category", "commercial_property_types.property_sub_type",
        'units.available_by')
      .to_a.group_by(&:neighborhood_name)
    running_list
  end

  def self.for_units(unit_ids, status=nil)
    listings = CommercialListing.joins([:commercial_property_type, unit: {building: [:company, :landlord]}])
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .where('units.archived = false')
      .where('units.id in (?)', unit_ids)
      .select('buildings.formatted_street_address',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'buildings.lat', 'buildings.lng', 'units.id AS unit_id', 'units.access_info','units.listing_id',
        'units.building_unit', 'units.status','units.rent', 'commercial_listings.sq_footage',
        'commercial_listings.id', 'commercial_listings.updated_at',
        'neighborhoods.name AS neighborhood_name',
        #'landlords.code AS landlord_code',
        'landlords.code',
        'landlords.id AS landlord_id',
        "commercial_property_types.property_type AS property_category", "commercial_property_types.property_sub_type",
        'units.available_by')

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

    images = CommercialListing.get_images(listings)
    bldg_images = Building.get_bldg_images_from_units(listings)
    return listings.distinct, images, bldg_images
  end

  def self.listings_by_id(user, listing_ids)
    running_list = CommercialListing.joins([:commercial_property_type, unit: {building: [:company, :landlord]}])
      .joins('left join neighborhoods on neighborhoods.id = buildings.neighborhood_id')
      .where('companies.id = ?', user.company_id)
      .where('units.listing_id IN (?)', listing_ids)
      .where('units.archived = false')
      .select('buildings.formatted_street_address',
        'buildings.id AS building_id', 'buildings.street_number', 'buildings.route',
        'buildings.lat', 'buildings.lng', 'units.id AS unit_id', 'units.access_info',
        'units.building_unit', 'units.status','units.rent', 'commercial_listings.sq_footage',
        'commercial_listings.id', 'commercial_listings.updated_at',
        'neighborhoods.name AS neighborhood_name',
        #'landlords.code AS landlord_code',
        'landlords.code',
        'landlords.id AS landlord_id',
        'commercial_property_types.property_type AS property_category', 'commercial_property_types.property_sub_type',
        'units.available_by', 'units.public_url')
    running_list
  end

  private
    def update_building_counts
      bldg = self.unit.building
      bldg.update_total_unit_count
      bldg.update_active_unit_count

      bldg.landlord.update_total_unit_count
      bldg.landlord.update_active_unit_count
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
