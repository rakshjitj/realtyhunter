class AddRoomshareDepartmentToResidentailListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :roomshare_department, :boolean
  end
end
