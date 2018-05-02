class AddDisplayOnWebsiteToImages < ActiveRecord::Migration[5.0]
  def change
  	add_column :images, :display_on_website, :boolean, default: true
  end
end
