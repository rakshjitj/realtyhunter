class AddPartialMoveInToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :partial_move_in, :boolean
  end
end
