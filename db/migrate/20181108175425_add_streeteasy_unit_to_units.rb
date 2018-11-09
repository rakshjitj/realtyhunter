class AddStreeteasyUnitToUnits < ActiveRecord::Migration[5.0]
  def change
  	add_column :units, :streeteasy_unit, :string
  end
end
