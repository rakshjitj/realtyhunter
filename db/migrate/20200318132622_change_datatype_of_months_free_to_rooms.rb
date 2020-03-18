class ChangeDatatypeOfMonthsFreeToRooms < ActiveRecord::Migration[5.0]
  def up
    change_column :rooms, :months_free, :float
  end
  def down
    change_column :rooms, :months_free, :integer
  end
end
