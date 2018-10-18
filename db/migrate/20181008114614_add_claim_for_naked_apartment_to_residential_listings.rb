class AddClaimForNakedApartmentToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :claim_for_naked_apartment, :text, array:true, default: []
  end
end
