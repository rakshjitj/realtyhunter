class UndoCreateNewListingTables < ActiveRecord::Migration
  # fix the bad migration on heroku
  
  def change
    drop_table 'residential_listings' if ActiveRecord::Base.connection.table_exists? 'residential_listings'
    drop_table 'commercial_listings' if ActiveRecord::Base.connection.table_exists? 'commercial_listings'
    drop_table 'residential_amenities_listings' if ActiveRecord::Base.connection.table_exists? 'residential_amenities_listings'

    change_table :units do |t|
      remove_column :units, :residential_listings_id
      remove_column :units, :commercial_listings_id
		end

    create_table :residential_listings do |t|
      t.integer :beds
      t.float   :baths
      t.string  :notes
      t.string  :description
      t.string :lease_start
      t.string :lease_end
      t.boolean :has_fee # means has broker's fee
      t.integer :op_fee_percentage
      t.integer :tp_fee_percentage
      t.boolean  :tenant_occupied, default: false
      t.timestamps null: false
      t.belongs_to :unit
    end

    create_table :commercial_listings do |t|
      t.integer :sq_footage
      t.integer :floor
      t.integer :building_size
      t.boolean :build_to_suit, default: false
      t.integer :minimum_divisible
      t.integer :maximum_contiguous
      t.integer :lease_type
      t.boolean :is_sublease, default: false #
      t.string  :property_description
      t.string  :location_description
      t.integer :construction_status, default: 0
      t.integer :no_parking_spaces
      t.integer :pct_procurement_fee
      t.integer :lease_term_months # different time frames than residential
      t.boolean :rate_is_negotiable
      t.integer :total_lot_size
      t.belongs_to :commercial_property_type
      t.timestamps null: false
      t.belongs_to :unit
    end

    change_table :units do |t|
      t.references :residential_listing, index: true
      t.references :commercial_listing, index: true
    end

    create_table :residential_amenities_listings, id: false do |t|
      t.belongs_to :residential_listing
      t.belongs_to :residential_amenity
    end

  end
end
