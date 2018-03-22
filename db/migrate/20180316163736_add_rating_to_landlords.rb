class AddRatingToLandlords < ActiveRecord::Migration[5.0]
  def change
  	add_column :landlords, :rating, :integer
  end
end
