class AddDotsignalCodeToBuildings < ActiveRecord::Migration[5.0]
  def change
  	add_column :buildings, :dotsignal_code, :integer
  end
end
