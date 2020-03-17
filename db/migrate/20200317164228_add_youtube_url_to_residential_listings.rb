class AddYoutubeUrlToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :youtube_video_url, :string
  end
end
