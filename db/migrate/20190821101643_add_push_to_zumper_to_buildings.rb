class AddPushToZumperToBuildings < ActiveRecord::Migration[5.0]
  def change
  	add_column :buildings, :push_to_zumper, :boolean, default: false
  end
end
