class DropOldData < ActiveRecord::Migration
  def change

  	drop_table 'residential_units'  if ActiveRecord::Base.connection.table_exists? 'residential_units'
  	drop_table 'commercial_units'  if ActiveRecord::Base.connection.table_exists? 'commercial_units'
		remove_column :units, :actable_id
		remove_column :units, :actable_type
  end
end

# class MoveDescripIntoUnits < ActiveRecord::Migration
#   def change
# 		remove_column :units, :listing_agent
# 		remove_column :landlords, :listing_agent_percentage
#   end
# end
