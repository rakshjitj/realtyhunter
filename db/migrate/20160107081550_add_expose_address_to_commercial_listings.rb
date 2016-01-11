class AddExposeAddressToCommercialListings < ActiveRecord::Migration
  def change
    add_column :commercial_listings, :expose_address, :boolean, default: false
  end
end
