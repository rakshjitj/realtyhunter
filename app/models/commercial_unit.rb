class CommercialUnit < ActiveRecord::Base
	acts_as :unit
  belongs_to :commercial_property_type
  before_validation :generate_unique_id
  scope :unarchived, ->{where(archived: false)}
  
  attr_accessor :property_type, :inaccuracy_description

  enum construction_status: [ :existing, :under_construction ]
  validates :construction_status, presence: true, inclusion: { in: %w(existing under_construction) }
  
  enum lease_type: [ :na, :full_service, :nnn, :modified_gross, :modified_net, :industrial_gross, :other ]
  validates :lease_type, presence: true, inclusion: { in: %w(na full_service nnn modified_gross modified_net industrial_gross other) }

	validates :sq_footage, presence: true, :numericality => { :less_than_or_equal_to => 99999999 }
	validates :floor, presence: true, :numericality => { :less_than_or_equal_to => 999 }
	validates :building_size, presence: true, :numericality => { :less_than_or_equal_to => 99999999 }

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
    # actable_type to restrict to residential only
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
      
    #     @running_list = @running_list.joins(:residential_amenities)
    #     .where('residential_amenity_id IN (?)', features)
    # end

    @running_list
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

  private
    def generate_unique_id
      self.listing_id = SecureRandom.random_number(9999999)
      while ResidentialUnit.find_by(listing_id: listing_id) do
        self.listing_id = rand(9999999)
      end
      self.listing_id
    end
end