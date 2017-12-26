class AddThumbImageUrlToImages < ActiveRecord::Migration[5.0]
  def change
  	add_column :images, :thumb_image_url, :string
  end
end
