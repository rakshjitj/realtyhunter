class AddLockToDeals < ActiveRecord::Migration
  def change
  	add_column :deals, :lock_version, :integer, default: 0, null: false
  	add_column :deals, :full_address, :string
  	add_column :deals, :building_unit, :string
  end
end
