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

  	# covers both commercial + residential
  	create_table :wufoo_listings_forms do |t|
			t.string :name
			t.string :email
			t.string :phone_number
			t.string :message
			t.boolean :is_residential
			t.boolean :is_commercial
			t.boolean :archived, default: false
			t.belongs_to :company
			t.timestamps null: false
  	end
  	
  	create_table :wufoo_partner_with_myspace_nyc_forms do |t|
			t.string :name
			t.string :email
			t.string :phone_number
			t.string :how_did_you_hear_about_us
			t.string :address
			t.integer :number_of_bedrooms
			t.string :renovated
			t.string :utilities
			t.datetime :datetime
			t.boolean :archived, default: false
			t.belongs_to :company
			t.timestamps null: false
  	end

  	change_table :companies do |t|
		  t.references :wufoo_contact_us_forms, index: true
		  t.references :wufoo_rental_listings_forms, index: true
		  t.references :wufoo_commercial_listings_forms, index: true
		  t.references :wufoo_partner_with_myspace_nyc_forms, index: true
		end

  end
end
