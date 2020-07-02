class AddPhotoStatusCompleteToPhotoGrapherToDos < ActiveRecord::Migration[5.0]
  def change
  	add_column :photo_grapher_to_dos, :completed, :boolean, default: false
  end
end
