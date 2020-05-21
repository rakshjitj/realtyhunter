class AddSomeFieldsToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :dimensions, :text
  	add_column :residential_listings, :photo_video_access, :text
  	add_column :residential_listings, :alt_address, :string
  end
end
