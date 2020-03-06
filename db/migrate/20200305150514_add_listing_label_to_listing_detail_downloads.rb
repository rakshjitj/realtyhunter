class AddListingLabelToListingDetailDownloads < ActiveRecord::Migration[5.0]
  def change
  	add_column :listing_detail_downloads, :listing_label, :string
  end
end
