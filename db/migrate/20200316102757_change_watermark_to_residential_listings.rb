class ChangeWatermarkToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :watermark_in_use, :integer
  end
end
