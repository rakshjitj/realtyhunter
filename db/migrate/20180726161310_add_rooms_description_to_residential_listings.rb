class AddRoomsDescriptionToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :rooms_description, :string
  end
end
