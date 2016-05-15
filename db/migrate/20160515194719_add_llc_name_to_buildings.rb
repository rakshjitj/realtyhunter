class AddLlcNameToBuildings < ActiveRecord::Migration
  def change
    add_column :buildings, :llc_name, :string
  end
end
