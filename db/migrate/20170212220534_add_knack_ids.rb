class AddKnackIds < ActiveRecord::Migration
  def change
    add_column :residential_listings, :knack_id, :string
    add_column :buildings, :knack_id, :string
    add_column :landlords, :knack_id, :string
  end
end
