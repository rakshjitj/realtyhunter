class ListingSerializer < ActiveModel::Serializer
	attributes :listing_type, :property_type, :commercial_use, :min_lease_term, 
	:max_lease_term, :renter_fee, :bathrooms, :unit_amenities, :unit_description,
	:floor, :layout, :bedrooms, :unit_number, :pets, :status, :building, :date_available,
	:changed_at, :square_footage, :rent, :id

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
		#object.primary_agents, each_serializer: PrimaryAgentSerializer
		if object.primary_agents
			object
	      .primary_agents
	      .map { |x| ActiveModel::Serializer::Adapter::Attributes.new(PrimaryAgentSerializer.new(x)).as_json }			
		end
	end

 	attributes :photos

  def photos
  	if object.images
	    object
	      .images
	      .map { |x| ActiveModel::Serializer::Adapter::Attributes.new(ListingImageSerializer.new(x)).as_json }
	  end
  end

	def listing_type
		#building.respond_to?("neighborhood_name".to_sym)
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
			if object.listing.tp_fee_percentage
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
			nil
		elsif is_commercial
			object.listing.floor
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

end