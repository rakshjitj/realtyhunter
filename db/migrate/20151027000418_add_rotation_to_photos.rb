class AddRotationToPhotos < ActiveRecord::Migration
  def change
  	add_column :images, :rotation, :integer, null: false, default: 0
  end
end

# class AddRotationToPhotos < ActiveRecord::Migration
#   def self.up
    
#   end
 
#   def self.down
#     remove_column :photos, :rotation
#   end
# end