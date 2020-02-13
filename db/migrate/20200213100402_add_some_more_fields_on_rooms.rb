class AddSomeMoreFieldsOnRooms < ActiveRecord::Migration[5.0]
  def change
  	add_column :rooms, :preferences, :text
  	add_column :rooms, :bonus, :text
  	add_column :rooms, :room_size, :string
  	add_column :rooms, :room_notes, :text
  	add_column :rooms, :tenant_info, :string
  end
end
