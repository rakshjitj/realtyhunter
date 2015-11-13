class RemoveForRoomsharingFromResidential < ActiveRecord::Migration
  def change
  	remove_column :residential_listings, :for_roomsharing
  end
end
