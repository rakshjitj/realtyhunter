class AddingLocks < ActiveRecord::Migration
  def change
    change_column :user_waterfalls, :agent_seniority_rate, :integer

  	add_column :users, :lock_version, :integer, default: 0, null: false
    add_column :buildings, :lock_version, :integer, default: 0, null: false
    add_column :landlords, :lock_version, :integer, default: 0, null: false
    add_column :residential_listings, :lock_version, :integer, default: 0, null: false
    add_column :commercial_listings, :lock_version, :integer, default: 0, null: false
    add_column :sales_listings, :lock_version, :integer, default: 0, null: false
    add_column :roommates, :lock_version, :integer, default: 0, null: false
    
  end
end
