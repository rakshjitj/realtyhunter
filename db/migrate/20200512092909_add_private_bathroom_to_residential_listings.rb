class AddPrivateBathroomToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :private_bathroom, :boolean, default: :false
  end
end
