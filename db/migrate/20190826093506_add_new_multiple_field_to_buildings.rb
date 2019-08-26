class AddNewMultipleFieldToBuildings < ActiveRecord::Migration[5.0]
  def change
  	add_column :buildings, :building_website, :text
  	add_column :buildings, :building_name, :string
  	add_column :buildings, :section_8, :boolean, default: false
  	add_column :buildings, :income_restricted, :boolean, default: false
  end
end
