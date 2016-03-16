class ListingSerializer < ActiveModel::Serializer
	attributes :listing_type, :property_type, :commercial_use, :min_lease_term,
	:max_lease_term, :renter_fee, :bathrooms, :unit_amenities, :unit_description,
	:floor, :layout, :bedrooms, :unit_number, :pets, :status, :building, :date_available,
	:changed_at, :square_footage, :rent, :id, :favorite, :show, :expose_address,
	:total_room_count, :condition, :showing_instruction, :commission_amount,
	:cyof, :rented_date, :rlsny, :share_with_brokers,
	:open_house_mon_from, :open_house_mon_to, :open_house_tue_from, :open_house_tue_to,
    :open_house_wed_from, :open_house_wed_to, :open_house_thu_from, :open_house_thu_to,
    :open_house_fri_from, :open_house_fri_to, :open_house_sat_from, :open_house_sat_to,
    :open_house_sun_from, :open_house_sun_to, :tenant_occupied, :op_fee_percentage,
    :rental_terms, :utilities

	attribute :building, serializer: BuildingSerializer

	def building
    BuildingSerializer.new(object.listing).attributes
  end

 attributes :contacts

  def is_residential
 	  object.listing.respond_to?(:r_id) && object.listing.r_id
  end

  def is_commercial
 	  object.listing.respond_to?(:c_id) && object.listing.c_id
  end

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
		if is_residential || is_commercial
			"rentals"
		else
			"sales"
		end
	end

	def property_type
		if is_residential
			"residential"
		elsif is_commercial
			"commercial"
		end
	end

	def commercial_use
		nil
	# 	if is_commercial && object.listing.commercial_property_type
	# 		object.listing.commercial_property_type.property_type
	# 	end
	end

	def min_lease_term
		if is_residential
			object.listing.lease_start
		elsif is_commercial
			object.listing.lease_term_months
		end
	end

	def max_lease_term
		if is_residential
			object.listing.lease_end
		elsif is_commercial
			object.listing.lease_term_months
		end
	end

	def renter_fee
		if is_residential
			if object.listing.r_has_fee # tp_fee_percentage
				"Fee"
			else
				"No Fee"
			end
		elsif is_commercial
			"Fee"
		end
	end

	def bathrooms
		if is_residential
			object.listing.baths
		elsif is_commercial
			nil
		end
	end

	def unit_amenities
		if object.residential_amenities #is_residential &&
			object.residential_amenities.map{|a| a.name}
		else
			nil
		end
	end

	def unit_description
		if is_residential
			object.listing.description
		elsif is_commercial
			object.listing.property_description
		end
	end

	def floor
		if is_residential
			object.listing.r_floor
		elsif is_commercial
			object.listing.c_floor
		end
	end

	def layout
		if is_residential
			object.listing.beds == 0 ? "Studio" : (object.listing.beds.to_s + ' Bedroom')
		else
			nil
		end
	end

	def bedrooms
		if is_residential
			object.listing.beds
		else
			nil
		end
	end

	def unit_number
		object.listing.building_unit
	end

	def pets
		if is_residential && object.pet_policies
			object.pet_policies[0].pet_policy_name
		else
			nil
		end
	end

	def rental_terms
		if is_residential && object.rental_terms
			object.rental_terms[0].rental_term_name
		else
			nil
		end
	end

	def utilities
		if is_residential && object.building_utilities
			object.building_utilities.map{|a| a.utility_name.titleize}.join(', ')
		else
			nil
		end
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

	# TODO: open_house

	def changed_at
		object.listing.updated_at
	end

	def square_footage
		if is_residential
			nil
		elsif is_commercial
			object.listing.sq_footage
		end
	end

	def rent
		object.listing.rent
	end

	def id
		object.listing.listing_id
	end

	def show
		if is_residential
			object.listing.r_show
		elsif is_commercial
			object.listing.c_show
		end
	end

	def favorite
		if is_residential
			object.listing.r_favorites
		elsif is_commercial
			object.listing.c_favorites
		end
	end

	def expose_address
		if is_residential
			object.listing.r_expose_address
		elsif is_commercial
			object.listing.c_expose_address
		end
	end

	def total_room_count
		if is_residential
			object.listing.total_room_count
		else
			nil
		end
	end

	def condition
		if is_residential
			object.listing.condition
		else
			nil
		end
	end

	def showing_instruction
		if is_residential
			object.listing.showing_instruction
		else
			nil
		end
	end

	def commission_amount
		if is_residential
			object.listing.commission_amount
		else
			nil
		end
	end

	def cyof
		if is_residential
			object.listing.cyof
		else
			nil
		end
	end

	def rented_date
		if is_residential
			object.listing.rented_date
		else
			nil
		end
	end

	def rlsny
		if is_residential
			object.listing.rlsny
		else
			nil
		end
	end

	def share_with_brokers
		if is_residential
			object.listing.share_with_brokers
		else
			nil
		end
	end

	def open_house_mon_from
		if is_residential
			object.listing.open_house_mon_from
		else
			nil
		end
	end

	def open_house_mon_to
		if is_residential
			object.listing.open_house_mon_to
		else
			nil
		end
	end

	def open_house_tue_from
		if is_residential
			object.listing.open_house_tue_from
		else
			nil
		end
	end

	def open_house_tue_to
		if is_residential
			object.listing.open_house_tue_to
		else
			nil
		end
	end

	def open_house_wed_from
		if is_residential
			object.listing.open_house_wed_from
		else
			nil
		end
	end

	def open_house_wed_to
		if is_residential
			object.listing.open_house_wed_to
		else
			nil
		end
	end

	def open_house_thu_from
		if is_residential
			object.listing.open_house_thu_from
		else
			nil
		end
	end

	def open_house_thu_to
		if is_residential
			object.listing.open_house_thu_to
		else
			nil
		end
	end

	def open_house_fri_from
		if is_residential
			object.listing.open_house_fri_from
		else
			nil
		end
	end

	def open_house_fri_to
		if is_residential
			object.listing.open_house_fri_to
		else
			nil
		end
	end

	def open_house_sat_from
		if is_residential
			object.listing.open_house_sat_from
		else
			nil
		end
	end

	def open_house_sat_to
		if is_residential
			object.listing.open_house_sat_to
		else
			nil
		end
	end

	def open_house_sun_from
		if is_residential
			object.listing.open_house_sun_from
		else
			nil
		end
	end

	def open_house_sun_to
		if is_residential
			object.listing.open_house_sun_to
		else
			nil
		end
	end

	def tenant_occupied
		if is_residential
			object.listing.tenant_occupied
		else
			nil
		end
	end

	def op_fee_percentage
		if is_residential
			object.listing.r_op_fee_percentage
		else
			nil
		end
	end
end
