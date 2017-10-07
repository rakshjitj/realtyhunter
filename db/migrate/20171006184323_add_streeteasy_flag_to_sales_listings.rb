class AddStreeteasyFlagToSalesListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :sales_listings, :streeteasy_flag, :boolean
  end
end
