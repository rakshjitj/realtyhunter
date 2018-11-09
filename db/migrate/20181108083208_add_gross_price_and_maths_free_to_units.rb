class AddGrossPriceAndMathsFreeToUnits < ActiveRecord::Migration[5.0]
  def change
  	add_column :units, :gross_price, :integer, default: 0
  	add_column :units, :maths_free, :float, default: 0
  end
end
