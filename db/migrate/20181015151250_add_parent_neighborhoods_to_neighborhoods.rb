class AddParentNeighborhoodsToNeighborhoods < ActiveRecord::Migration[5.0]
  def change
  	add_column :neighborhoods, :parent_neighborhoods, :integer, default: 0
  end
end
