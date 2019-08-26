class AddYearBuildToBuildings < ActiveRecord::Migration[5.0]
  def change
  	add_column :buildings, :year_build, :string
  end
end
