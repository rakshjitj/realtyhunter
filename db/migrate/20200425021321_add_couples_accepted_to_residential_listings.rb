class AddCouplesAcceptedToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :couples_accepted, :boolean, default: :false
  end
end
