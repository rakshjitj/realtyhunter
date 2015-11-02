class RoommateAddedFields < ActiveRecord::Migration
  def change
  	# keeps track of whether a new roommate has been
  	# viewed or not
  	add_column :roommates, :read, :boolean, default: false
  	# keeps track of whether an apartment can be 
  	# used for roommsharing
  	add_column :residential_listings, :for_roomsharing, :boolean, default: false
  end
end
