class ResidentialUnit < ActiveRecord::Base
	acts_as :unit
	has_and_belongs_to_many :residential_amenities

  #autocomplete :building, :formatted_street_address

  attr_accessor :include_photos, :inaccuracy_description

	enum lease_duration: [ :year, :thirteen_months, :fourteen_months, :fifteen_months, 
		:sixteen_months, :seventeen_months, :eighteen_months, :two_years ]
	validates :lease_duration, presence: true, inclusion: { 
    in: %w(year thirteen_months fourteen_months fifteen_months sixteen_months seventeen_months eighteen_months two_years) }

	validates :beds, presence: true, :numericality => { :less_than_or_equal_to => 11 }
	validates :baths, presence: true, :numericality => { :less_than_or_equal_to => 11 }

  # used as a sorting condition
  def street_address_and_unit
    self.building.street_number + ' ' + self.building.route + ' #' + self.building_unit
  end

  # used as a sorting condition
  def landlord_by_code
    self.building.landlord.code
  end

  # used as a sorting condition
  def bed_and_baths
    "#{beds} / #{baths}"
  end

	def amenities_to_s
		amenities = self.residential_amenities.map{|a| a.name}
		if amenities
			amenities.join(", ")
		else
			"None"
		end
	end

	def self.generate_unique_id
		listing_id = rand(9999999)
    while ResidentialUnit.find_by(listing_id: listing_id) do
      listing_id = rand(9999999)
    end
    listing_id
  end

  # takes in a hash of search options
  # can be formatted_street_address, landlord
  # status, unit, bed_min, bed_max, bath_min, bath_max, rent_min, rent_max, 
  # neighborhoods, has_outdoor_space, features, pet_policy
  def self.search(params, building_id)
    # actable_type to restrict to residential only
    if !params && !building_id
      return ResidentialUnit.all
    elsif !params && building_id
      return ResidentialUnit.where(building_id: building_id)
    end

    @running_list = Unit.all
    
    # clear out any invalid search params
    params.delete_if{|k,v| !v || v.empty? }

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

    # search by unit
    if params[:unit]
      @running_list = @running_list.where("building_unit = ?", params[:unit])
    end

    # search by status
    #status = %w[active pending off].include?(params[:status])
    #if status
    #  @running_list = @running_list.where("status = ?", status)
    #end

    # search by rent
    if params[:rent_min] && params[:rent_max]
      @running_list = @running_list.where("rent >= ? AND rent <= ?", params[:rent_min], params[:rent_max])
    elsif params[:rent_min] && !params[:rent_max]
      @running_list = @running_list.where("rent >= ?", params[:rent_min])
    elsif !params[:rent_min] && params[:rent_max]
      @running_list = @running_list.where("rent <= ?", params[:rent_max])
    end

    # search neighborhoods
    if params[:neighborhoods]
      @running_list = @running_list.joins(:building)
       .where('neighborhood_id IN (?)', params[:neighborhoods])
    end

    # search features
    if params[:features]
      features = params[:features][0, 256]
      @terms = features.split(" ")
      @terms.each do |term|
        @running_list = @running_list.joins(building: :building_amenities)
        .where('building_amenities.name ILIKE ?', "%#{term}%")
        #puts "\n\n #{@running_list[0].building_amenities.inspect}"
      end
    end

    # search landlord code
    if params[:landlord]
      @running_list = @running_list.joins(building: :landlord)
      .where("code ILIKE ?", "%#{params[:landlord]}%")
    end

    # search pet policy
    if params[:pet_policy_id]
      @running_list = @running_list.joins(building: :landlord)
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

    @running_list
	end

  def duplicate(new_unit_num, include_photos)
    if new_unit_num
      residential_unit_dup = self.dup
      residential_unit_dup.listing_id = ResidentialUnit.generate_unique_id
      residential_unit_dup.building_unit = new_unit_num
      # TODO: photos
      residential_unit_dup.save
      residential_unit_dup
    else
      raise "no unit number specified"
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

    case(lease_duration)
    when "year"
      end_date = Date.today >> 12
    when "thirteen_months"
      end_date = Date.today >> 13
    when "fourteen_months"
      end_date = Date.today >> 14
    when "fifteen_months"
      end_date = Date.today >> 15
    when "sixteen_months"
      end_date = Date.today >> 16
    when "seventeen_months"
      end_date = Date.today >> 17
    when "eighteen_months"
      end_date = Date.today >> 18
    when "two_years"
      end_date = Date.today >> 24
    else
      end_date = Date.today >> 12
    end
    
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

end
