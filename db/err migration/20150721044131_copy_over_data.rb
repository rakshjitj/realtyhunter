class CopyOverData < ActiveRecord::Migration
  def up
  	# copy over residential
  	execute "insert into residential_listings (beds, baths, notes, description, lease_start, lease_end, has_fee, 
  		op_fee_percentage, tp_fee_percentage, tenant_occupied, unit_id, created_at, updated_at) (
select beds, baths, notes, description, lease_start, lease_end, has_fee, op_fee_percentage, 
tp_fee_percentage, tenant_occupied, units.id AS unit_id, created_at, updated_at
from residential_units
left join units 
on units.actable_id = residential_units.id
where units.actable_type = 'ResidentialUnit');"
		
		# copy over residential amenities
    execute "insert into residential_amenities_listings (residential_listing_id, residential_amenity_id) 
(select residential_listings.id as res_listing_id, residential_amenities_units.residential_amenity_id
from residential_amenities_units
left join residential_units
on residential_amenities_units.residential_unit_id = residential_units.id
left join units
on residential_units.id = units.actable_id
left join residential_listings
on residential_listings.unit_id = units.id
order by residential_amenities_units.residential_unit_id);"

		# copy over commercial
		execute "insert into commercial_listings (sq_footage, floor, building_size, build_to_suit, minimum_divisible, 
maximum_contiguous,lease_type, property_description, location_description, construction_status, no_parking_spaces,
pct_procurement_fee, lease_term_months, rate_is_negotiable, total_lot_size, commercial_property_type_id, 
unit_id, created_at, updated_at) (
select sq_footage, floor, building_size, build_to_suit, minimum_divisble, 
maximum_contiguous,lease_type, property_description, location_description, construction_status, no_parking_spaces,
pct_procurement_fee, lease_term_months, rate_is_negotiable, total_lot_size, commercial_property_type_id, 
units.id AS unit_id, created_at, updated_at
from commercial_units
left join units 
on units.actable_id = commercial_units.id
where units.actable_type = 'CommercialUnit');"

  end

  def down
    drop_table :residential_amenities_listings
    remove_column :residential_listings, :description, :string
		execute "truncate residential_listings;"
		execute "truncate commercial_listings;"
  end

end
