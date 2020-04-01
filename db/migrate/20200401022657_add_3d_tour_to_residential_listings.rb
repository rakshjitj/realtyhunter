class Add3dTourToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :tour_3d, :string
  end
end
