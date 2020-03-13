class AddMonthsFreeToRooms < ActiveRecord::Migration[5.0]
  def change
  	add_column :rooms, :months_free, :integer
  end
end
