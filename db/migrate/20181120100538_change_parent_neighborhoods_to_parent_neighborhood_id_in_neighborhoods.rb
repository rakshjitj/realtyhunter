class ChangeParentNeighborhoodsToParentNeighborhoodIdInNeighborhoods < ActiveRecord::Migration[5.0]
  def change
  	rename_column :neighborhoods, :parent_neighborhoods, :parent_neighborhood_id
  end
end
