class ChangeColumnName < ActiveRecord::Migration
  def change
  	rename_column :residential_listings, :floor_number, :floor
  	rename_column :sales_listings, :floor_number, :floor
  end
end
