class AddAgentToApplication < ActiveRecord::Migration
  def change
  	remove_column :roomsharing_applications, :agent_name, :string
  	add_reference :roomsharing_applications, :user, index: true
  end
end
