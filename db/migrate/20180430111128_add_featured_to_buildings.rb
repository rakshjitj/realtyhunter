class AddFeaturedToBuildings < ActiveRecord::Migration[5.0]
  def change
  	add_column :buildings, :featured, :boolean, default: false
  end
end
