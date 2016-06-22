class APISalesListingSerializer < ActiveModel::Serializer
  # common to all units
  attributes :unit_description, :building, :open_houses, :contacts, :photos,
  :floor, :layout, :bedrooms, :unit_number, :pets, :status, :date_available,
  :changed_at, :rent, :id,
  :total_room_count, :condition, :showing_instruction, :commission_amount,
  :cyof, :rlsny, :share_with_brokers,
  :listing_type, :property_type, :commercial_use,
  :bathrooms, :unit_amenities,
  # unique to sales - this line and down
  :percent_commission, :outside_broker_commission,
  :seller_name, :seller_phone, :seller_address,
  :year_built, :building_type, :lot_size, :building_size,
  :block_taxes, :lot_taxes, :water_sewer, :insurance,
  :school_district, :certificate_of_occupancy, :violation_search

  # not used in sales:
  # :square_footage, :favorite, :show, :expose_address, :rented_date, :rental_terms, :utilities,
  # :min_lease_term, :max_lease_term, :renter_fee,

  def open_houses
    if object.open_houses
      object.open_houses
        .map { |x| OpenHouseSerializer.new(x).attributes }
    end
  end

  def building
    APIBuildingSerializer.new(object.building_blob).attributes
  end

  def contacts
    if object.primary_agents
      object
        .primary_agents
        .map { |x| PrimaryAgentSerializer.new(x).attributes }
    end
  end

  def photos
    if object.images
      object
        .images
        .map { |x| ListingImageSerializer.new(x).attributes }
    end
  end

  def listing_type
    object.listing.listing_type
  end

  def property_type
    "residential"
  end

  def commercial_use
    nil
  end

  # def min_lease_term
  #   if is_residential
  #     object.listing.lease_start
  #   elsif is_commercial
  #     object.listing.lease_term_months
  #   else #sales
  #     nil
  #   end
  # end

  # def max_lease_term
  #   if is_residential
  #     object.listing.lease_end
  #   elsif is_commercial
  #     object.listing.lease_term_months
  #   else #sales
  #     nil
  #   end
  # end

  # def renter_fee
  #   if is_residential
  #     if object.listing.r_has_fee # tp_fee_percentage
  #       "Fee"
  #     else
  #       "No Fee"
  #     end
  #   elsif is_commercial
  #     "Fee"
  #   else
  #     nil
  #   end
  # end

  def bathrooms
    object.listing.baths
  end

  def unit_amenities
    if object.residential_amenities
      object.residential_amenities.map{|a| a.name}
    else
      nil
    end
  end

  def unit_description
    object.listing.public_description
  end

  def floor
    object.listing.s_floor
  end

  def layout
    object.listing.beds == 0 ? "Studio" : (object.listing.beds.to_s + ' Bedroom')
  end

  def bedrooms
    object.listing.beds
  end

  def unit_number
    object.listing.building_unit
  end

  def pets
    if object.pet_policies
      object.pet_policies[0].pet_policy_name
    else
      nil
    end
  end

  # todo: do we want to condense this down further?
  # 'on_market', 'contract_out', 'in_escrow', 'closed'] }
  def status
    object.listing.status ? object.listing.status.humanize.titleize : nil
  end

  def date_available
    if object.listing.available_by
      object.listing.available_by.strftime("%Y-%m-%d")
    else
      nil
    end
  end

  def changed_at
    object.listing.updated_at
  end

  # def square_footage
  #   if is_commercial
  #     object.listing.sq_footage
  #   else
  #     nil
  #   end
  # end

  def rent
    object.listing.rent
  end

  def id
    object.listing.listing_id
  end

  # def show
  #   if is_residential
  #     object.listing.r_show
  #   elsif is_commercial
  #     object.listing.c_show
  #   else
  #     nil # why is there no show for sales?
  #   end
  # end

  # def favorite
  #   if is_residential
  #     object.listing.r_favorites
  #   elsif is_commercial
  #     object.listing.c_favorites
  #   else
  #     nil # why is there no favorites for sales?
  #   end
  # end

  # def expose_address
  #   if is_residential
  #     object.listing.r_expose_address
  #   elsif is_commercial
  #     object.listing.c_expose_address
  #   else
  #     nil # why is there no expose_address for sales?
  #   end
  # end

  def total_room_count
    object.listing.s_total_room_count
  end

  def condition
    object.listing.s_condition
  end

  def showing_instruction
    object.listing.s_showing_instruction
  end

  def commission_amount
    object.listing.s_commission_amount
  end

  def cyof
    object.listing.s_cyof
  end

  def rlsny
    object.listing.s_rlsny
  end

  def share_with_brokers
    object.listing.s_share_with_brokers
  end

  def tenant_occupied
    object.listing.s_tenant_occupied
  end

  # def op_fee_percentage
  #   if is_residential
  #     object.listing.r_op_fee_percentage
  #   else
  #     nil
  #   end
  # end

  # def rental_terms
  #   if is_residential && object.rental_terms
  #     object.rental_terms[0].rental_term_name
  #   else
  #     nil
  #   end
  # end

  # def utilities
  #   if is_residential && object.building_utilities
  #     object.building_utilities.map{|a| a.utility_name.titleize}.join(', ')
  #   else
  #     nil
  #   end
  # end

  def percent_commission
    object.listing.percent_commission
  end

  def outside_broker_commission
    object.listing.outside_broker_commission
  end

  def seller_name
    object.listing.seller_name
  end

  def seller_phone
    object.listing.seller_phone
  end

  def seller_address
    object.listing.seller_address
  end

  def year_built
    object.listing.year_built
  end

  def building_type
    object.listing.building_type
  end

  def lot_size
    object.listing.lot_size
  end

  def building_size
    object.listing.building_size
  end

  def block_taxes
    object.listing.block_taxes
  end

  def lot_taxes
    object.listing.lot_taxes
  end

  def water_sewer
    object.listing.water_sewer
  end

  def insurance
    object.listing.insurance
  end

  def school_district
    object.listing.school_district
  end

  def certificate_of_occupancy
    object.listing.certificate_of_occupancy
  end

  def violation_search
    object.listing.violation_search
  end

end
