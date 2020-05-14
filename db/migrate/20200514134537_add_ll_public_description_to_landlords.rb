class AddLlPublicDescriptionToLandlords < ActiveRecord::Migration[5.0]
  def change
  	add_column :landlords, :ll_public_description, :text
  end
end
