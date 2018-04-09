class AddAgentHideToUsers < ActiveRecord::Migration[5.0]
  def change
  	add_column :users, :agent_hide, :boolean, default: true
  end
end
