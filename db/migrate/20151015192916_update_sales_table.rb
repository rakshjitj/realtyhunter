class UpdateSalesTable < ActiveRecord::Migration
  def change
  
  	add_column :sales_listings, :internal_notes, :string
  	add_column :sales_listings, :public_description, :string

  	add_column :sales_listings, :listing_type, :string
  	add_column :sales_listings, :percent_commission, :float
  	add_column :sales_listings, :outside_broker_commission, :float
  	add_column :sales_listings, :seller_name, :string
  	add_column :sales_listings, :seller_phone, :string
  	add_column :sales_listings, :seller_address, :string
		add_column :sales_listings, :year_built, :string
		add_column :sales_listings, :building_type, :string
		add_column :sales_listings, :lot_size, :integer
		add_column :sales_listings, :building_size, :integer
		add_column :sales_listings, :block_taxes, :integer
		add_column :sales_listings, :lot_taxes, :integer
		add_column :sales_listings, :water_sewer, :integer
		add_column :sales_listings, :insurance, :integer
  	add_column :sales_listings, :school_district, :string
  	add_column :sales_listings, :certificate_of_occupancy, :string
  	add_column :sales_listings, :violation_search, :string

  	remove_column :sales_listings, :lease_start, :string
  	remove_column :sales_listings, :lease_end, :string
  	remove_column :sales_listings, :has_fee, :boolean
  	remove_column :sales_listings, :op_fee_percentage, :integer
  	remove_column :sales_listings, :tp_fee_percentage, :integer
  	remove_column :sales_listings, :price, :integer
  	remove_column :sales_listings, :notes, :string
  	remove_column :sales_listings, :description, :string

  	#add_column :units, :listing_title, :string

  	drop_table :sales_amenities_units

  	create_table :sales_amenities_listings, id: false do |t|
      t.belongs_to :sales_listing
      t.belongs_to :sales_amenity
    end

  end
end
