class AddResidentialListingIdToRooms < ActiveRecord::Migration[5.0]
  def change
  	add_column :rooms, :residential_listing_id, :integer
  end
end
