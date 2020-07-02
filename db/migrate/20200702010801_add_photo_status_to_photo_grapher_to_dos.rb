class AddPhotoStatusToPhotoGrapherToDos < ActiveRecord::Migration[5.0]
  def change
  	add_column :photo_grapher_to_dos, :photo_status, :text
  end
end
