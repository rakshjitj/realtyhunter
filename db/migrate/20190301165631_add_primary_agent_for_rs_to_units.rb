class AddPrimaryAgentForRsToUnits < ActiveRecord::Migration[5.0]
  def change
  	add_column :units, :primary_agent_for_rs, :integer
  end
end
