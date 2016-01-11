class ChangeColumnDefaultToCommercialListings < ActiveRecord::Migration
  def change
  	change_column_default :commercial_listings, :favorites, true
  end
end
