class ChangePropertyTaxToSalesListings < ActiveRecord::Migration[5.0]
  def change
  	change_column :sales_listings, :property_tax, :float
  end
end
