class AddNewFieldsToSalesListing < ActiveRecord::Migration[5.0]
  def change
  	add_column :sales_listings, :listing_name, :string
  	add_column :sales_listings, :number_of_floors, :integer
  	add_column :sales_listings, :internal_sq_footage, :integer
  	add_column :sales_listings, :number_of_units, :integer
  	add_column :sales_listings, :number_of_retail_spaces, :integer
  end
end
