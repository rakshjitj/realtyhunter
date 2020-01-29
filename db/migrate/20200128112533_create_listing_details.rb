class CreateListingDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :listing_details do |t|
      t.datetime :a
      t.integer :b
      t.integer :c

      t.timestamps
    end
  end
end
