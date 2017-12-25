class AddStreeteasyListingEmailAndNumberToUnits < ActiveRecord::Migration[5.0]
  def change
  	add_column :units, :streeteasy_listing_email, :string
  	add_column :units, :streeteasy_listing_number, :string
  end
end
