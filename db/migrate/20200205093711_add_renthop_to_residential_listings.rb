class AddRenthopToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :renthop, :boolean, default: false
  end
end
