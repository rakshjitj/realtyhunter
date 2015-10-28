class AddRotationToPhotos < ActiveRecord::Migration
  def change
  	add_column :images, :rotation, :integer, null: false, default: 0
  end
end