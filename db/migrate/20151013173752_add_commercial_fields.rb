class AddCommercialFields < ActiveRecord::Migration
  def change
  	add_column :commercial_listings, :liquor_eligible, :boolean
  	add_column :commercial_listings, :has_basement, :boolean
  	add_column :commercial_listings, :basement_sq_footage, :string
  	add_column :commercial_listings, :has_ventilation, :boolean
  	add_column :commercial_listings, :key_money_required, :boolean
  	add_column :commercial_listings, :key_money_amt, :integer
  	add_column :commercial_listings, :listing_title, :string
  	#add_references :commercial_listings, :primary_agent2, index: true
  end
end
