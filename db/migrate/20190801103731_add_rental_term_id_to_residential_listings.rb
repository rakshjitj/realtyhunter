class AddRentalTermIdToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :rental_term_id, :integer
  end
end
