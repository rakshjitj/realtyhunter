class AddRsOnlyDescriptionToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :rs_only_description, :text
  end
end
