class AddFavoritesShowFields < ActiveRecord::Migration
  def change
    add_column :residential_listings, :favorites, :boolean, default: false
    add_column :residential_listings, :show, :boolean, default: true
    add_column :commercial_listings, :favorites, :boolean, default: true
    add_column :commercial_listings, :show, :boolean, default: true
  end
end
