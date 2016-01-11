class AddFavoritesToResidentialListings < ActiveRecord::Migration
  def change
    add_column :residential_listings, :favorites, :boolean, default: false
  end
end
