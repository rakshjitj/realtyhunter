class AddNakedApartmentOnResidentialListing < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :naked_apartment, :boolean, default: false
  end
end
