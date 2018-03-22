class AddRatingToBuildings < ActiveRecord::Migration[5.0]
  def change
  	add_column :buildings, :rating, :integer
  end
end
