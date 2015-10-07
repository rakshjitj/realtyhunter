class AddWufooTables < ActiveRecord::Migration
  def change
  	create_table :roommates do |t|
  		t.string :name
			t.string :phone_number
			t.string :email
			t.string :how_did_you_hear_about_us
			t.string :upload_picture_of_yourself
			t.string :describe_yourself
			t.string :monthly_budget
			t.datetime :move_in_date
			t.belongs_to :neighborhood #what_neighborhood_do_you_want_to_live_in
			t.boolean :dogs_allowed
			t.boolean :cats_allowed
			t.string :created_by
			t.boolean :archived, default: false
			t.belongs_to :company
  		t.belongs_to :user
			t.timestamps null: false
  	end

  	change_table :companies do |t|
		  t.references :roommates, index: true
		end

		change_table :users do |t|
		  t.references :roommates, index: true
		end

		change_table :neighborhoods do |t|
		  t.references :roommates, index: true
		end

		change_table :images do |t|
		  t.belongs_to :roommate, index: true
		end

  	create_table :wufoo_contact_us_forms do |t|
			t.string :name
			t.string :phone_number
			t.string :email
			t.string :how_did_you_hear_about_us
			t.string :min_price
			t.string :max_price
			t.string :any_notes_for_us
			t.boolean :archived, default: false
			t.timestamps null: false
  	end

  	create_table :wufoo_rental_listings_forms do |t|
			t.string :name
			t.string :email
			t.string :phone_number
			t.string :message
			t.boolean :archived, default: false
			t.timestamps null: false
  	end

  	create_table :wufoo_commercial_listings_forms do |t|
			t.string :name
			t.string :email
			t.string :phone_number
			t.string :message
			t.boolean :archived, default: false
			t.timestamps null: false
  	end

  	create_table :wufoo_partner_with_myspace_nyc_forms do |t|
			t.string :name
			t.string :email
			t.string :phone_number
			t.string :how_did_you_hear_about_us
			t.string :address
			t.string :number_of_bedrooms
			t.string :renovated
			t.string :utilities
			t.datetime :datetime
			t.boolean :archived, default: false
			t.timestamps null: false
  	end
  end
end
