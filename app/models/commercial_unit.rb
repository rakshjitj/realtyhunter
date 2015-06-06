class CommercialUnit < ActiveRecord::Base
	acts_as :unit
  belongs_to :commercial_property_type
  
  enum construction_status: [ :existing, :under_construction ]
  validates :construction_status, presence: true, inclusion: { in: %w(existing under_construction) }
  
	validates :sq_footage, presence: true, :numericality => { :less_than_or_equal_to => 99999999 }
	validates :floor, presence: true, :numericality => { :less_than_or_equal_to => 999 }
	validates :building_size, presence: true, :numericality => { :less_than_or_equal_to => 99999999 }

	# used as a sorting condition
  def landlord_by_code
    self.building.landlord.code
  end

  def summary
  	summary = self.status.capitalize() + ' - ' + self.property_type
  	if self.property_sub_type
  		summary += ' (' + self.property_sub_type + ')'
  	end

  	summary
  end

  # TODO
  def num_space_in_bldg
  	'-'
  end

  def price_per_sq_ft
    self.rent / self.sq_footage
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

end