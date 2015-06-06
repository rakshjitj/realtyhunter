class CommercialUnit < ActiveRecord::Base
	acts_as :unit
  belongs_to :commercial_property_type
  attr_accessor :property_type, :inaccuracy_description

  enum construction_status: [ :existing, :under_construction ]
  validates :construction_status, presence: true, inclusion: { in: %w(existing under_construction) }
  
  enum lease_type: [ :na, :full_service, :nnn, :modified_gross, :modified_net, :industrial_gross, :other ]
  validates :lease_type, presence: true, inclusion: { in: %w(na full_service nnn modified_gross modified_net industrial_gross other) }

	validates :sq_footage, presence: true, :numericality => { :less_than_or_equal_to => 99999999 }
	validates :floor, presence: true, :numericality => { :less_than_or_equal_to => 999 }
	validates :building_size, presence: true, :numericality => { :less_than_or_equal_to => 99999999 }

	# used as a sorting condition
  def landlord_by_code
    self.building.landlord.code
  end

  def summary
  	summary = self.status.capitalize() + ' - ' + self.commercial_property_type.property_type
  	if self.commercial_property_type.property_sub_type
  		summary += ' (' + self.commercial_property_type.property_sub_type + ')'
  	end

  	summary
  end

  def price_per_sq_ft
    self.rent.to_f / self.sq_footage
  end

  def self.search(params, building_id=nil)
    # actable_type to restrict to residential only
    if !params && !building_id
      return CommercialUnit.all
    elsif !params && building_id
      return CommercialUnit.where(building_id: building_id)
    end

    @running_list = Unit.all
    
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

    # search by unit
    if params[:unit]
      @running_list = @running_list.where("building_unit = ?", params[:unit])
    end

    # search by status
    if params[:status]
      included = %w[active pending off].include?(params[:status])
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

    # search landlord code
    if params[:landlord]
      @running_list = @running_list.joins(building: :landlord)
      .where("code ILIKE ?", "%#{params[:landlord]}%")
    end

    @running_list = Unit.get_commercial(@running_list)
    @running_list
  end

  def duplicate(new_unit_num, include_photos)
    if new_unit_num
      commercial_unit_dup = self.dup
      commercial_unit_dup.listing_id = Unit.generate_unique_id
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

end