class AddPointOfContactToBuildings < ActiveRecord::Migration[5.0]
  def change
  	add_column :buildings, :point_of_contact, :integer
  end
end
