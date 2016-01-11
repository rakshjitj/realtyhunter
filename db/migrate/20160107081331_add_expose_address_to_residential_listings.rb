class AddExposeAddressToResidentialListings < ActiveRecord::Migration
  def change
    add_column :residential_listings, :expose_address, :boolean, default: false
  end
end
