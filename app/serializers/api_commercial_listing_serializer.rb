class APICommercialListingSerializer < ActiveModel::Serializer
  # common to all units
  attributes :unit_description,
  :floor, :layout, :bedrooms, :unit_number, :pets, :status, :date_available,
  :changed_at, :square_footage, :rent, :id, :favorite, :show, :expose_address,
  :total_room_count, :condition, :showing_instruction, :commission_amount,
  :cyof, :rented_date, :rlsny, :share_with_brokers,
  :rental_terms, :utilities, :listing_type, :property_type, :commercial_use, :min_lease_term,
  :max_lease_term, :renter_fee, :bathrooms, :unit_amenities

  attribute :open_houses
  def open_houses
    if object.open_houses
      object.open_houses
        .map { |x| OpenHouseSerializer.new(x).attributes }
    end
  end

  attribute :building, serializer: BuildingSerializer
  def building
    BuildingSerializer.new(object.listing).attributes
  end

  attributes :contacts
  def contacts
    if object.primary_agents
      object
        .primary_agents
        .map { |x| PrimaryAgentSerializer.new(x).attributes }
    end
  end

  attributes :photos
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
    "commercial"
  end

  # todo: remove? not used by anything.
  def commercial_use
    nil
  end

  def min_lease_term
    object.listing.lease_term_months
  end

  def max_lease_term
    object.listing.lease_term_months
  end

  def renter_fee
    "Fee"
  end

  def bathrooms
    nil
  end

  def unit_amenities
    nil
  end

  def unit_description
    object.listing.property_description
  end

  def floor
    object.listing.c_floor
  end

  def layout
    nil
  end

  def bedrooms
    nil
  end

  def unit_number
    object.listing.building_unit
  end

  def pets
    nil
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
    object.listing.sq_footage
  end

  def rent
    object.listing.rent
  end

  def id
    object.listing.listing_id
  end

  def show
    object.listing.c_show
  end

  def favorite
    object.listing.c_favorites
  end

  def expose_address
    object.listing.c_expose_address
  end

  def total_room_count
    nil
  end

  def condition
    nil
  end

  def showing_instruction
    nil
  end

  def commission_amount
    nil
  end

  def cyof
    nil
  end

  def rented_date
    nil
  end

  def rlsny
    nil
  end

  def share_with_brokers
    nil
  end

  def tenant_occupied
    nil
  end

  def op_fee_percentage
    nil
  end

  def rental_terms
    nil
  end

  def utilities
    nil
  end

end
