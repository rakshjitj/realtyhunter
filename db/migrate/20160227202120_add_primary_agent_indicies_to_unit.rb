class AddPrimaryAgentIndiciesToUnit < ActiveRecord::Migration
  def change
    add_index "units", ["primary_agent_id"]
  end
end
