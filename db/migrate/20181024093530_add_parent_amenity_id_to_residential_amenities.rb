class AddParentAmenityIdToResidentialAmenities < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_amenities, :parent_amenity_id, :integer, default: 0
  end
end
