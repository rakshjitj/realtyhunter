json.prettify! if %w(1 yes true).include?(params["pretty"])

json.extract! listing, :sq_footage, :floor, :building_size,
	:build_to_suit, :minimum_divisble, :maximum_contiguous,
	:lease_type, :is_sublease, :property_description, :location_description, :construction_status,
	:no_parking_spaces, :pct_procurement_fee, :lease_term_months, :rate_is_negotiable, :total_lot_size

json.extract! listing, :rent, :status

json.date_available listing.available_by.strftime('%Y-%m-%d')

json.changed_at listing.updated_at

#json.photos

json.building do
	json.partial! listing.building, building: listing.building, as: :building
end

json.contacts do 
	json.array! listing.contacts do
  	json.agent_id listing.primary_agent.id
  	json.phone_number listing.primary_agent.phone_number
  	json.mobile_phone_number listing.primary_agent.mobile_phone_number
  	json.name listing.primary_agent.name
  	json.email listing.primary_agent.email
	end
end

json.id listing.listing_id

