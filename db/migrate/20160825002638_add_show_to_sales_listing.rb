class AddShowToSalesListing < ActiveRecord::Migration
  def change
    add_column :sales_listings, :show, :boolean, default: true
    add_column :sales_listings, :favorites, :boolean, default: true
    add_column :sales_listings, :expose_address, :boolean, default: false
  end
end
