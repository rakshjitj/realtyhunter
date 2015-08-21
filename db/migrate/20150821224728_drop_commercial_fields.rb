class DropCommercialFields < ActiveRecord::Migration
  def change
  	remove_column :buildings, :has_fee, :boolean
    remove_column :buildings, :op_fee_percentage, :integer
    remove_column :buildings, :tp_fee_percentage, :integer
    remove_column :commercial_listings, :pct_procurement_fee, :integer
    remove_column :commercial_listings, :no_parking_spaces, :integer
  end
end
