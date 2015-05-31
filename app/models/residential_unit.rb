class ResidentialUnit < ActiveRecord::Base
	acts_as :unit
	has_and_belongs_to_many :residential_amenities
  
  attr_accessor :include_photos, :inaccuracy_description

	enum lease_duration: [ :half_year, :year, :thirteen_months, :fourteen_months, :fifteen_months, 
		:sixteen_months, :seventeen_months, :eighteen_months, :two_years ]
	
	validates :beds, presence: true, :numericality => { :less_than_or_equal_to => 11 }
	validates :baths, presence: true, :numericality => { :less_than_or_equal_to => 11 }

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

  def self.search(query_str, active_only)
		@running_list = ResidentialUnit.all
    if !query_str
      return @running_list
    end
    
    # cap query string length for security reasons
  	query_str = query_str[0, 256]

    @terms = query_str.split(" ")
    # TODO:
    #@terms.each do |term|
    #  @running_list = @running_list.joins(:buildings)
    #  .where('building.formatted_street_address ILIKE ? OR unit ILIKE ?', "%#{term}%", "%#{term}%")
    #end

    if active_only == "true"
    	@running_list = @running_list.where(status: "active")
    end

    @running_list.uniq
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

end
