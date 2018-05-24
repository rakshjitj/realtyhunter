class AddFeaturedToUnits < ActiveRecord::Migration[5.0]
  def change
  	add_column :units, :featured, :boolean, default: false
  end
end
