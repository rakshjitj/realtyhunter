class CreateSalesListings < ActiveRecord::Migration
  def change

    create_table :sales_listings do |t|
  		t.integer "price" # used instead of rent
	  	t.integer  "beds"
	    t.float    "baths"
	    t.string   "notes"
	    t.string   "description"
	    t.string   "lease_start"
	    t.string   "lease_end"
	    t.boolean  "has_fee"
	    t.integer  "op_fee_percentage"
	    t.integer  "tp_fee_percentage"
	    t.boolean  "tenant_occupied", default: false
	    t.datetime "created_at", null: false
	    t.datetime "updated_at", null: false
	    t.belongs_to :unit
      t.timestamps null: false
    end

	  change_table :units do |t|
		  t.references :sales_listing, index: true
		end

	  create_table :sales_amenities do |t|
      t.string :name
      t.belongs_to :company
      t.timestamps null: false
    end

    create_table :sales_amenities_units, id: false do |t|
      t.belongs_to :sales_listing
      t.belongs_to :sales_amenity
    end

    change_table :companies do |t|
    	t.references :sales_amenities, index: true
    end
  end
end
