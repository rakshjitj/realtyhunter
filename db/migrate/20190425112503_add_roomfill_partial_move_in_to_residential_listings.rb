class AddRoomfillPartialMoveInToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :roomfill_partial_move_in, :boolean, default: false
  end
end
