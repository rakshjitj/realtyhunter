class AddMoreIndices < ActiveRecord::Migration
  def change

		remove_column :units, :listing_agent_id
		remove_column :landlords, :listing_agent_percentage, :integer
  	add_index :users, :auth_token
  end
end
