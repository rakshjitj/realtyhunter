class APIResidentialListingSerializer < ActiveModel::Serializer
  # common to all units
  attributes :building, :open_houses, :contacts, :photos, :unit_description,
  :floor, :layout, :bedrooms, :unit_number, :pets, :status, :date_available,
  :changed_at, :square_footage, :rent, :id, :favorite, :show, :expose_address,
  :total_room_count, :condition, :showing_instruction, :commission_amount,
  :cyof, :rented_date, :rlsny, :share_with_brokers, :rls_flag, :streeteasy_flag,
  :rental_terms, :utilities, :listing_type, :property_type, :commercial_use, :min_lease_term,
  :max_lease_term, :renter_fee, :bathrooms, :unit_amenities

  def open_houses
    if object.open_houses
      object.open_houses
        .map { |x| OpenHouseSerializer.new(x).attributes }
    end
  end

  # attribute :building, serializer: BuildingSerializer
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
    "rentals"
  end

  def property_type
    "residential"
  end

  def commercial_use
    nil
  end

  def min_lease_term
    object.listing.lease_start
  end

  def max_lease_term
    object.listing.lease_end
  end

  def renter_fee
    if object.listing.r_has_fee # tp_fee_percentage
      "Fee"
    else
      "No Fee"
    end
  end

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
    object.listing.description
  end

  def floor
    object.listing.r_floor
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
    object.pet_policies ? object.pet_policies[0].pet_policy_name : nil
  end

  def status
    if object.listing.status == "active"
      "Active"
    elsif object.listing.status == "pending" ||
      object.listing.status == "offer_submitted" ||
      object.listing.status == "offer_accepted" ||
      object.listing.status == "binder_signed"
        "App Pending"
    elsif object.listing.status == "off" ||
      object.listing.status == "off_market_for_lease_execution"
      "Lease Out"
    end
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

  def square_footage
    nil
  end

  def rent
    object.listing.rent
  end

  def id
    object.listing.listing_id
  end

  def show
    object.listing.r_show
  end

  def favorite
    object.listing.r_favorites
  end

  def expose_address
    object.listing.r_expose_address
  end

  def total_room_count
    object.listing.r_total_room_count
  end

  def condition
    object.listing.r_condition
  end

  def showing_instruction
    object.listing.r_showing_instruction
  end

  def commission_amount
    object.listing.r_commission_amount
  end

  def cyof
    object.listing.r_cyof
  end

  def rented_date
    object.listing.r_rented_date
  end

  def rlsny
    object.listing.r_rlsny
  end

  def share_with_brokers
    object.listing.r_share_with_brokers
  end

  def tenant_occupied
    object.listing.r_tenant_occupied
  end

  def op_fee_percentage
    object.listing.r_op_fee_percentage
  end

  def rental_terms
    if object.rental_terms
      object.rental_terms[0].rental_term_name
    else
      nil
    end
  end

  def utilities
    if object.building_utilities
      object.building_utilities.map{|a| a.utility_name.titleize}.join(', ')
    else
      nil
    end
  end

  def rls_flag
    object.listing.rls_flag
  end

  def streeteasy_flag
    object.listing.streeteasy_flag
  end
end
