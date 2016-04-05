class AddIndexOnUsers < ActiveRecord::Migration
  def change
    add_index :users, :updated_at, order: { updated_at: "DESC NULLS LAST" }
    add_index :residential_listings, :updated_at, order: { updated_at: "DESC NULLS LAST" }
    remove_index :buildings, :updated_at
    add_index :buildings, :updated_at, order: { updated_at: "DESC NULLS LAST" }
    add_index :landlords, :updated_at, order: { updated_at: "DESC NULLS LAST" }
  end
end
