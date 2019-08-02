class AddResidentialListingIdToRentalTerms < ActiveRecord::Migration[5.0]
  def change
  	add_column :rental_terms, :residential_listing_id, :integer
  end
end
