class AddParentAmenitiesToResidentialAmenities < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_amenities, :parent_amenities, :integer, default: 0
  end
end
