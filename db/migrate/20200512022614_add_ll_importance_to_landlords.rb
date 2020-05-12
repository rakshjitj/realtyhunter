class AddLlImportanceToLandlords < ActiveRecord::Migration[5.0]
  def change
  	add_column :landlords, :ll_importance, :string
  end
end
