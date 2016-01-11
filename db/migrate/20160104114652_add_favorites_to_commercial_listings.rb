class AddFavoritesToCommercialListings < ActiveRecord::Migration
  def change
    add_column :commercial_listings, :favorites, :boolean, default: false
  end
end
