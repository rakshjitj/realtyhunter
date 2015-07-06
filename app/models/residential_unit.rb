class ResidentialUnit < ActiveRecord::Base
	acts_as :unit
  scope :unarchived, ->{where(archived: false)}
  has_and_belongs_to_many :residential_amenities
  before_validation :generate_unique_id

  attr_accessor :include_photos, :inaccuracy_description

  validates :building_unit, presence: true, length: {maximum: 50}

	# enum lease_duration: [ :year, :thirteen_months, :fourteen_months, :fifteen_months, 
	# 	:sixteen_months, :seventeen_months, :eighteen_months, :two_years ]
	validates :lease_duration, presence: true, length: {maximum: 50} #inclusion: { 
  #  in: %w(year thirteen_months fourteen_months fifteen_months sixteen_months seventeen_months eighteen_months two_years) }
  
  validates :rent, presence: true, :numericality => { :greater_than => 0 }
	validates :beds, presence: true, :numericality => { :less_than_or_equal_to => 11 }
	validates :baths, presence: true, :numericality => { :less_than_or_equal_to => 11 }
  
  validates :op_fee_percentage, allow_blank: true, length: {maximum: 3}, numericality: { only_integer: true }
  validates_inclusion_of :op_fee_percentage, :in => 0..100, allow_blank: true

  validates :tp_fee_percentage, allow_blank: true, length: {maximum: 3}, numericality: { only_integer: true }
  validates_inclusion_of :tp_fee_percentage, :in => 0..100, allow_blank: true

  validates :weeks_free_offered, allow_blank: true, length: {maximum: 3}, numericality: { only_integer: true }

  def archive
    self.archived = true
    self.save
  end

  def self.find_unarchived(id)
    find_by!(id: id, archived: false)
  end

  # used as a sorting condition
  def street_address_and_unit
    if building.street_number
      building.street_number + ' ' + building.route + ' #' + building_unit
    else
      building.route + ' #' + building_unit
    end
  end

  # used as a sorting condition
  def landlord_by_code
    building.landlord.code
  end

  # used as a sorting condition
  def bed_and_baths
    "#{beds} / #{baths}"
  end

	def amenities_to_s
		amenities = residential_amenities.map{|a| a.name}
		amenities ? amenities.join(", ") : "None"
	end

  # mainly for use in our API. Returns list of any
  # agent contacts for this listing. Currently we have
  # 1 primary agent for each listing, but could change in the future.
  def contacts
    contacts = [primary_agent];
  end

  # For now, always calculate off a 12 month lease
  # def net_rent

    # months = 12

    # case(lease_duration)
    # when "year"
    #   months = 12
    # when "thirteen_months"
    #   months = 13
    # when "fourteen_months"
    #   months = 14
    # when "fifteen_months"
    #   months = 15
    # when "sixteen_months"
    #   months = 16
    # when "seventeen_months"
    #   months = 17
    # when "eighteen_months"
    #   months = 18
    # when "two_years"
    #   months = 24
    # else
    #   months = 12
    # end
    
    # total_rent = rent * months
    # rent_per_week = total_rent / (months * 4)
    # net_rent = total_rent - (rent_per_week * weeks_free_offered)
    # net_rent_per_month = net_rent / months
    # net_rent_per_month
  # end

  # mainly used in API
  # prints layout in Nestio's format
  def beds_to_s
    beds == 0 ? "Studio" : (beds.to_s + ' Bedroom')
  end

  # takes in a hash of search options
  # can be formatted_street_address, landlord
  # status, unit, bed_min, bed_max, bath_min, bath_max, rent_min, rent_max, 
  # neighborhoods, has_outdoor_space, features, pet_policy
  def self.search(params, building_id=nil)
    @running_list = Unit.includes(:building, :images).unarchived

    # actable_type to restrict to residential only
    if !params && !building_id
      return Unit.get_residential(@running_list)
      #return ResidentialUnit.unarchived
    elsif !params && building_id
      return ResidentialUnit.includes(:images).unarchived.where(building_id: building_id)
    end

    # all search params come in as strings from the url
    # clear out any invalid search params
    params.delete_if{|k,v| (!v || v == 0 || v.empty?) }

    # search by address (building)
    if params[:address]
      # cap query string length for security reasons
    	address = params[:address][0, 500]
      @running_list = @running_list.joins(:building)
       .where('formatted_street_address ILIKE ?', "%#{address}%")
    end

    # search by unit
    if params[:unit]
      @running_list = @running_list.where("building_unit = ?", params[:unit])
    end

    # search by status
    if params[:status]
      included = %w[Active Pending Off].include?(params[:status])
      if included
       @running_list = @running_list.where("status = ?", Unit.statuses[params[:status].downcase])
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

    if params[:building_feature_ids]
      features = params[:building_feature_ids][0, 256]
      features = features.split(",")
        @running_list = @running_list.joins(building: :building_amenities)
        .where('building_amenity_id IN (?)', features)
    end

    # search landlord code
    if params[:landlord]
      @running_list = @running_list.joins(building: :landlord)
      .where("code ILIKE ?", "%#{params[:landlord]}%")
    end

    # search pet policy
    # TODO: test again
    if params[:pet_policy_id]
      @running_list = @running_list.joins(building: :pet_policy)
        .where('pet_policy_id = ?', params[:pet_policy_id])
    end

    # the following fields are on ResidentialUnit not Unit, so cast the 
    # objects first
    @running_list = Unit.get_residential(@running_list)

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

    # search features
    if params[:unit_feature_ids]
      features = params[:unit_feature_ids][0, 256]
      features = features.split(",")
        @running_list = @running_list.joins(:residential_amenities)
        .where('residential_amenity_id IN (?)', features)
    end
    
    @running_list.uniq
	end

  def duplicate(new_unit_num, include_photos)
    if new_unit_num && new_unit_num != self.id
      # copy object
      residential_unit_dup = self.dup
      residential_unit_dup.building_unit = new_unit_num
      residential_unit_dup.save
      # deep copy photos
      self.images.each {|i| 
        img_copy = Image.new
        img_copy.file = i.file
        img_copy.unit_id = residential_unit_dup.id
        img_copy.save
        residential_unit_dup.images << img_copy
      }

      residential_unit_dup
    else
      raise "No unit number or invalid unit number specified"
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
    @map_infos = {}
    for i in 0..runits.length-1
      street_address = runits[i].building.street_address
      bldg_info = {
        building_id: runits[i].building.id,
        lat: runits[i].building.lat, 
        lng: runits[i].building.lng }
      unit_info = {
        id: runits[i].id,
        building_unit: runits[i].building_unit,
        beds: runits[i].beds,
        baths: runits[i].baths,
        rent: runits[i].rent }

      if @map_infos.has_key?(street_address)
        @map_infos[street_address]['units'] << unit_info
      else
        bldg_info['units'] = [unit_info]
        @map_infos[street_address] = bldg_info
      end
    end

    @map_infos
  end

  private
    def generate_unique_id
      self.listing_id = SecureRandom.random_number(9999999)
      while ResidentialUnit.find_by(listing_id: listing_id) do
        self.listing_id = rand(9999999)
      end
      self.listing_id
    end
end
