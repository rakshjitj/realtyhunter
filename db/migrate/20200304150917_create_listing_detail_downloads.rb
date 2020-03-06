class CreateListingDetailDownloads < ActiveRecord::Migration[5.0]
  def change
    create_table :listing_detail_downloads do |t|
      t.string :address
      t.string :unit
      t.string :se_unit
      t.string :poc
      t.string :llc
      t.integer :price
      t.integer :listing_detail_id
      t.timestamps
    end
  end
end
