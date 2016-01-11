class AddShowToResidentialListings < ActiveRecord::Migration
  def change
    add_column :residential_listings, :show, :boolean, default: true
  end
end
