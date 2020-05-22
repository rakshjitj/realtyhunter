class AddTenantDescriptionToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :tenant_description, :text
  end
end
