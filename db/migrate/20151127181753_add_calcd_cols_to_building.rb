class AddCalcdColsToBuilding < ActiveRecord::Migration
  def change
  	add_column :buildings, :total_unit_count, :integer, default: 0, null: false
  	add_column :buildings, :active_unit_count, :integer, default: 0, null: false
  	add_column :buildings, :last_unit_updated_at, :datetime
  	add_column :landlords, :total_unit_count, :integer, default: 0, null: false
  	add_column :landlords, :active_unit_count, :integer, default: 0, null: false
  	add_column :landlords, :last_unit_updated_at, :datetime
  end

end
