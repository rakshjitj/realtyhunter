class DropAgentTypesTable < ActiveRecord::Migration
  def change
  	drop_table 'agent_types'  if ActiveRecord::Base.connection.table_exists? 'agent_types'
  end
end
