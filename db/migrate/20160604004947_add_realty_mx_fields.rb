class AddRealtyMxFields < ActiveRecord::Migration
  def change
    add_column :residential_listings, :rls_flag, :boolean, default: false
    add_column :residential_listings, :streeteasy_flag, :boolean, default: false
  end
end
