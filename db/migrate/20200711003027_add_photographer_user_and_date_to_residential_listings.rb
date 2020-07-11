class AddPhotographerUserAndDateToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :photographer_user_id, :integer
  	add_column :residential_listings, :photographer_update_date, :date 
  end
end
