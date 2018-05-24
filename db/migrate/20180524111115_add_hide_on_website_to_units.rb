class AddHideOnWebsiteToUnits < ActiveRecord::Migration[5.0]
  def change
  	add_column :units, :hide_on_website, :boolean, default: false
  end
end
