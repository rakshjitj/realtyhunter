class ChangeYearBuildFromStringToIntegerToBuildings < ActiveRecord::Migration[5.0]
  def up
    change_column :buildings, :year_build, :string
  end
  def down
    change_column :buildings, :year_build, :integer
  end
end
