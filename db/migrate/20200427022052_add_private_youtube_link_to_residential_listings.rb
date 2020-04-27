class AddPrivateYoutubeLinkToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :private_youtube_url, :string
  end
end
