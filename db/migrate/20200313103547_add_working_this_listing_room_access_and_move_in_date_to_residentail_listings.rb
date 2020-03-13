class AddWorkingThisListingRoomAccessAndMoveInDateToResidentailListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :working_this_listing, :boolean, default: :false
  	add_column :residential_listings, :room_access, :string
  	add_column :residential_listings, :move_in_date, :timestamp
  end
end
