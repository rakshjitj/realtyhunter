class AddThirdTierToBuildings < ActiveRecord::Migration[5.0]
  def change
  	add_column :buildings, :third_tier, :boolean, default: :false
  end
end
