class AddAgentSeniority < ActiveRecord::Migration
  def change
  	# agents collect different commission rates depending on 
  	# their seniority
  	add_column :user_waterfalls, :agent_seniority_rate, :float
  end
end
