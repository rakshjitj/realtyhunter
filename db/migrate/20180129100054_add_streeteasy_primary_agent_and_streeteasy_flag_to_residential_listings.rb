class AddStreeteasyPrimaryAgentAndStreeteasyFlagToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :units, :streeteasy_primary_agent_id, :integer
  	add_column :residential_listings, :streeteasy_flag_one, :boolean
  end
end
