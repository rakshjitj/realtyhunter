class DropWufooTables < ActiveRecord::Migration[5.0]
  def change
  	drop_table :wufoo_career_forms
  	drop_table :wufoo_contact_us_forms
  	drop_table :wufoo_listings_forms
  	drop_table :wufoo_partner_forms
  end
end
