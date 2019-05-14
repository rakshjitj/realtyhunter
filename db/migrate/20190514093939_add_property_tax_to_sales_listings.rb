class AddPropertyTaxToSalesListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :sales_listings, :property_tax, :integer
  end
end
