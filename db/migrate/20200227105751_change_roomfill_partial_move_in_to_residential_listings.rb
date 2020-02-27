class ChangeRoomfillPartialMoveInToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	rename_column :residential_listings, :roomfill_partial_move_in, :roomfill
  end
end
