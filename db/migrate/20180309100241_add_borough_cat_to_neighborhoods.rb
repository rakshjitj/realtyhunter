class AddBoroughCatToNeighborhoods < ActiveRecord::Migration[5.0]
  def change
  	add_column :neighborhoods, :borough_cat, :string
  end
end
