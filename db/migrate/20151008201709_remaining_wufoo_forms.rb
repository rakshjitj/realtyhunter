class RemainingWufooForms < ActiveRecord::Migration
  def change
  	create_table :wufoo_contact_us_forms do |t|
			t.string :name
			t.string :phone_number
			t.string :email
			t.string :how_did_you_hear_about_us
			t.integer :min_price
			t.integer :max_price
			t.string :any_notes_for_us
			t.belongs_to :company
			t.boolean :archived, default: false
			t.timestamps null: false
  	end

  	create_table :wufoo_partner_forms do |t|
			t.string :name
			t.string :email
			t.string :phone_number
			t.string :how_did_you_hear_about_us
			t.string :address_street_address
			t.string :address_address_line_2
			t.integer :address_city
			t.string :address_state_province_region
			t.string :address_postal_zip_code
			t.string :address_country
			t.integer :number_of_bedrooms
			t.boolean :renovated
			t.boolean :utilities_heat_included
			t.boolean :utilities_hot_water_included
			t.boolean :utilities_gas_included
			t.boolean :utilities_electric_included
			t.boolean :utilities_no_utilities_included
			t.datetime :move_in_date
			t.boolean :archived, default: false
			t.belongs_to :company
			t.timestamps null: false
  	end

  	# # covers both commercial + residential
  	# create_table :wufoo_listings_forms do |t|
			# t.string :name
			# t.string :email
			# t.string :phone_number
			# t.string :message
			# t.boolean :is_residential
			# t.boolean :is_commercial
			# t.boolean :archived, default: false
			# t.belongs_to :company
			# t.timestamps null: false
  	# end
  	
  	change_table :companies do |t|
		  t.references :wufoo_contact_us_forms, index: true
		  t.references :wufoo_partner_forms, index: true
		  #t.references :wufoo_listings_forms, index: true
		end

  end
end
