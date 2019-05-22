class AddCommonChargesToSalesListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :sales_listings, :common_chargers, :float
  end
end
