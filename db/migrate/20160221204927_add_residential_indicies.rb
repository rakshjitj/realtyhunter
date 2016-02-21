class AddResidentialIndicies < ActiveRecord::Migration
  def change
    # add_index "residential_amenities_listings", ["residential_listing_id", "residential_amenity_id"],
    #   name: 'res_am_listings_join_index'
    add_index "residential_listings", ["unit_id"]
    add_index "commercial_listings", ["unit_id"]
    add_index "sales_listings", ["unit_id"]
    add_index "images", ["unit_id"]
    add_index "images", ["building_id"]
    add_index "users", ["office_id"]
    add_index "units", ["updated_at", "status", "archived"]
  end
end
