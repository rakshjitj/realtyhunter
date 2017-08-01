class AddExposeAddress < ActiveRecord::Migration
  def change
    add_column :residential_listings, :expose_address, :boolean, default: false
    add_column :commercial_listings, :expose_address, :boolean, default: false
  end
end
