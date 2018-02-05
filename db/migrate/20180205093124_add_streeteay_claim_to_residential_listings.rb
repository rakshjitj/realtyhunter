class AddStreeteayClaimToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :streeteasy_claim, :boolean, default: false
  end
end
