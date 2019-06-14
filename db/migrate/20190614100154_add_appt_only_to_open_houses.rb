class AddApptOnlyToOpenHouses < ActiveRecord::Migration[5.0]
  def change
  	add_column :open_houses, :appt_only, :boolean, default: false
  end
end
