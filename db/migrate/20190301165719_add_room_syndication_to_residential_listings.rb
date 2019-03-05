class AddRoomSyndicationToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :room_syndication, :boolean, default: false
  end
end
