class ChangeListingAgent < ActiveRecord::Migration
  def change

  	# should not be on landlord
  	add_reference :buildings, :listing_agent, index: true
  	add_column :buildings, :listing_agent_percentage, :integer

  	# is now by default on the building
  	# but can be overridden in an individual listing
  	add_column :buildings, :has_fee, :boolean # means if it has broker's fee
  	add_column :buildings, :op_fee_percentage, :integer
  	add_column :buildings, :tp_fee_percentage, :integer

  	# drop all the old data!
		#drop_column :units, :listing_agent
		#drop_column :landlords, :listing_agent_percentage

    add_column :landlords, :update_source, :string
  end
end
