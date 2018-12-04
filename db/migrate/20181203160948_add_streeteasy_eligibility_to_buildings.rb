class AddStreeteasyEligibilityToBuildings < ActiveRecord::Migration[5.0]
  def change
  	add_column :buildings, :streeteasy_eligibility, :integer, default: 1
  end
end
