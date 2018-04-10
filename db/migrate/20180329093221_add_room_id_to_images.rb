class AddRoomIdToImages < ActiveRecord::Migration[5.0]
  def change
  	add_column :images, :room_id, :integer
  end
end
