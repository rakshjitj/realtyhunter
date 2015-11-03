class RoommateAddedFields < ActiveRecord::Migration
  def change
  	# keeps track of whether a new roommate has been
  	# viewed or not
  	add_column :roommates, :read, :boolean, default: false
  	# keeps track of whether an apartment can be 
  	# used for roommsharing
  	add_column :residential_listings, :for_roomsharing, :boolean, default: false

  	# create a mapping for roommates that have been assigned to residential aparments
    add_reference :residential_listings, :roommates, index: true
    # 	change_table :residential_listings do |t|
		#   t.references :roommates, index: true
		# end
		# change_table :roommates do |t|
		#   t.belongs_to :residential_listings
		# end

    add_reference :roommates, :residential_listing

  end
end
