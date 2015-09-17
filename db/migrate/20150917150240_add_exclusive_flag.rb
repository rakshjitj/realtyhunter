class AddExclusiveFlag < ActiveRecord::Migration
  def change
  	add_column :units, :exclusive, :boolean
  end
end
