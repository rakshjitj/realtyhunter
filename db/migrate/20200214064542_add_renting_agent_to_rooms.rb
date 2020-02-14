class AddRentingAgentToRooms < ActiveRecord::Migration[5.0]
  def change
  	add_column :rooms, :renting_agent, :string
  end
end
