class AddShowToCommercialListings < ActiveRecord::Migration
  def change
    add_column :commercial_listings, :show, :boolean, default: true
  end
end
