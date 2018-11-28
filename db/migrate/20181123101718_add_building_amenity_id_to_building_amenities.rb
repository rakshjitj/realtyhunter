class AddBuildingAmenityIdToBuildingAmenities < ActiveRecord::Migration[5.0]
  def change
  	add_column :building_amenities, :building_parent_amenity_id, :integer, default: 0
  end
end
