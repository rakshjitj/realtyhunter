class AddWatermarkToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :watermark, :boolean, default: :false
  end
end
