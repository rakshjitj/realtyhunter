class AddMoreIndices < ActiveRecord::Migration
  def change

		#remove_column :units, :listing_agent
		remove_column :landlords, :listing_agent_percentage, :integer
  	add_index :users, :auth_token
  	# add_index :units, :building_id
  	# add_index :buildings, :neighborhood_id
  	# add_index :buildings, :pet_policy_id
  end
end
