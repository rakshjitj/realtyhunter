class ChagneBedsFormatInResidentailListings < ActiveRecord::Migration[5.0]
  def change
  	change_column :residential_listings, :beds, :float
  end
end
