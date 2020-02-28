class AddHideFromAgentToUnits < ActiveRecord::Migration[5.0]
  def change
  	add_column :units, :hide_from_agent, :boolean, default: :false
  end
end
