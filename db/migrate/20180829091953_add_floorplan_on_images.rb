class AddFloorplanOnImages < ActiveRecord::Migration[5.0]
  def change
  	add_column :images, :floorplan, :boolean, default: false
  end
end
