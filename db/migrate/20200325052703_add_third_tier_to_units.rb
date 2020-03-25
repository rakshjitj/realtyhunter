class AddThirdTierToUnits < ActiveRecord::Migration[5.0]
  def change
  	add_column :units, :third_tier, :boolean, default: :false
  end
end
