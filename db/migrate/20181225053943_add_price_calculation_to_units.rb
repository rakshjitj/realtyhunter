class AddPriceCalculationToUnits < ActiveRecord::Migration[5.0]
  def change
  	add_column :units, :price_calculation, :boolean, default: true
  end
end
